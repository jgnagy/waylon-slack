# Waylon::Slack

The Slack _Sense_ for the [Waylon](https://github.com/jgnagy/waylon-core) Bot Framework. This allows Waylon to interact with Slack via the Slack [Web API](https://api.slack.com/web) and [Events API](https://api.slack.com/events) (for sending and receiving messages, respectively).

## Installation

Add this line to your bot's Gemfile:

```ruby
gem 'waylon-slack'
```

Or, if your bot is itself a gem, add this to your .gemspec:

```ruby
spec.add_dependency "waylon-slack", "~> 0.1"
```

And then execute:

    $ bundle install

Or install it yourself via:

    $ gem install waylon-slack

## Usage

You'll need both your webhook server and your workers to have a line like this:

```ruby
# right after 'require "waylon"'...
require "waylon/slack"
```

That should get it working in your bot. You'll also need to ensure that these environment variables are properly defined based on your bot's [Slack app setup](https://api.slack.com/authentication/basics):

```sh
SLACK_OAUTH_TOKEN="xoxb-..."
SLACK_SIGNING_SECRET="..."
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jgnagy/waylon-slack.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
