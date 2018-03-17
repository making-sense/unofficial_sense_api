# Unofficial Sense Api

Access your Sense data.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'unofficial_sense_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install unofficial_sense_api

## Usage

Getting Realtime Data (starts a websocket to `wss://clientrt.sense.com/monitors/#{api.first_monitor_id}/realtimefeed`)

```ruby
require 'sense_api'
require 'pp'

api = SenseApi.new("USERNAME", "PASSWORD")

count = 0
api.realtime do |json|
  pp json

  # Be sure to return :exit to terminate the connection and shut down EventMachine!
  count += 1
  count > 5 ? :exit : nil
end
```

Use `fetch` to pull from REST endpoints of your choice. None have been added to this gem yet.

```ruby
require 'sense_api'
api = SenseApi.new("USERNAME", "PASSWORD")

timeline = api.fetch("https://api.sense.com/apiservice/api/v1/users/#{api.user_id}/timeline?n_item=30")

trends = api.fetch("https://api.sense.com/apiservice/api/v1/app/history/trends?monitor_id=#{api.first_monitor_id}&scale=WEEK&start=2017-10-23T04:00:00.000Z")

devices = api.fetch("https://api.sense.com/apiservice/api/v1/app/monitors/#{api.first_monitor_id}/devices?include_merged=true")

first_device_id = devices.first["id"]

first_device_details = api.fetch("https://api.sense.com/apiservice/api/v1/app/monitors/#{api.first_monitor_id}/devices/#{first_device_id}")
first_device_hostory = api.fetch("https://api.sense.com/apiservice/api/v1/app/history/usage?monitor_id=#{api.first_monitor_id}&granularity=MINUTE&start=2017-10-21T11:00:00.000Z&frames=5400&device_id=#{first_device_id}")
```

Here are the endpoints we know about so far:

* `"https://api.sense.com/apiservice/api/v1/users/#{api.user_id}/timeline?n_item=30"`
* `"https://api.sense.com/apiservice/api/v1/app/history/trends?monitor_id=#{api.first_monitor_id}&scale=WEEK&start=2017-10-23T04:00:00.000Z"`
* `"https://api.sense.com/apiservice/api/v1/app/history/usage?monitor_id=#{api.first_monitor_id}&granularity=SECOND&start=2017-10-25T03:54:00.000Z&frames=5400"` (`granularity` seems to accept `SECOND` or `MINUTE`)

List devices:
* `"https://api.sense.com/apiservice/api/v1/app/monitors/#{api.first_monitor_id}/devices?include_merged=true"`

You can add a `device_id` to the history request:
* `"https://api.sense.com/apiservice/api/v1/app/history/usage?monitor_id=#{api.first_monitor_id}&granularity=MINUTE&start=2017-10-21T11:00:00.000Z&frames=5400&device_id=SOME_DEVICE_ID"`

And get the data for devices:
* `"https://api.sense.com/apiservice/api/v1/app/monitors/#{api.first_monitor_id}/devices/always_on"`
* `"https://api.sense.com/apiservice/api/v1/app/monitors/#{api.first_monitor_id}/devices/unknown"`
* `"https://api.sense.com/apiservice/api/v1/app/monitors/#{api.first_monitor_id}/devices/SOME_DEVICE_ID"`

### Accessing the API with Curl

If you'd like, you can skip Ruby entirely and talk to the Sense API with curl:

`curl -k --data "email=email@example.com" --data "password=URL_ENCODED_PASSWORD" -H "Sense-Client-Version: 1.17.1-20c25f9" -H "X-Sense-Protocol: 3" -H "User-Agent: okhttp/3.8.0" "https://api.sense.com/apiservice/api/v1/authenticate"`

The response will have an `access_token`, as well as a `user_id` and a `monitors` array that you can use to access the Sense APIs. For example:

`curl -k -H "Authorization: bearer ACCESS_TOKEN" -H "Sense-Client-Version: 1.17.1-20c25f9" -H "X-Sense-Protocol: 3" -H "User-Agent: okhttp/3.8.0" "https://api.sense.com/apiservice/api/v1/app/history/usage?monitor_id=A_MONITOR_ID&granularity=SECOND&start=2017-10-24T05:36:00.000Z&frames=5400"`

## Development

You can run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
