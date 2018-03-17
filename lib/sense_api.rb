require "sense_api/version"
require 'net/http'
require 'openssl'
require 'json'
require 'eventmachine'
require 'websocket/eventmachine/client'

class SenseApi
  attr_accessor :email, :password, :token, :monitors, :user_id, :account_id

  class SenseApiError < StandardError; end

  def initialize(email, password, token: nil, monitors: nil)
    self.email = email
    self.password = password
    self.token = token
    self.monitors = monitors

    login! unless token
  end

  def fetch(url, depth = 0)
    uri = URI(url)
    req = Net::HTTP::Get.new(uri)

    req['Authorization'] = "bearer #{token}"
    req['Sense-Client-Version'] = '1.17.1-20c25f9'
    req['X-Sense-Protocol'] = '3'
    req['User-Agent'] = 'okhttp/3.8.0'

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE  
    res = http.request(req)

    case res
    when Net::HTTPRedirection
      if depth < 2
        fetch(res['Location'], depth + 1)
      else
        raise SenseApiError, "Too many redirects"
      end
    when Net::HTTPSuccess
      JSON.parse(res.body)
    else
      raise SenseApiError, "Error: #{res.value}" 
    end
  end

  def first_monitor_id
    monitors.first["id"]
  end

  def realtime(monitor_id = first_monitor_id)
    raise ArgumentError, "block required" unless block_given?

    exiting = false
    EM.run do
      ws = WebSocket::EventMachine::Client.connect(
        uri: "wss://clientrt.sense.com/monitors/#{monitor_id}/realtimefeed",
        headers: {
          'Authorization' => "bearer #{token}",
          'Sense-Client-Version' => '1.17.1-20c25f9',
          'X-Sense-Protocol' => '3',
          'User-Agent' => 'okhttp/3.8.0'
        },
        tls_options: { fail_if_no_peer_cert: false, verify_peer: false }
      )

      ws.onmessage do |msg, type|
        if yield(JSON.parse(msg)) == :exit
          exiting = true
          ws.close
        end
      end

      ws.onclose do |code, reason|
        raise SenseApiError, "Connection closed: #{code} #{reason}" unless exiting
        EM.stop_event_loop
      end
    end
  end

  private

  def login!
    uri = URI('https://api.sense.com/apiservice/api/v1/authenticate')
    req = Net::HTTP::Post.new(uri)

    req.set_form_data(email: email, password: password)
    req['Sense-Client-Version'] = '1.17.1-20c25f9'
    req['X-Sense-Protocol'] = '3'
    req['User-Agent'] = 'okhttp/3.8.0'

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE  
    res = http.request(req)

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      json = JSON.parse(res.body)
      if json["authorized"]
        self.token = json["access_token"]
        self.monitors = json["monitors"]
        self.account_id = json["account_id"]
        self.user_id = json["user_id"]
      else
        raise SenseApiError, "Login failed"
      end
    else
      raise SenseApiError, "Error: #{res.value}" 
    end
  end
end
