# frozen_string_literal: true

require "waylon/core"
require "slack-ruby-client"

::Slack.configure do |conf|
  conf.token = ENV.fetch("SLACK_OAUTH_TOKEN", nil)
  conf.logger = Waylon::Logger.logger
end

::Slack::Web::Client.configure do |conf|
  conf.user_agent = "Waylon/#{Waylon::Core::VERSION}"
  conf.logger = Waylon::Logger.logger
end

require_relative "slack/version"
require_relative "slack/user"
require_relative "slack/channel"
require_relative "slack/message"
require_relative "senses/slack"
require_relative "webhooks/slack"
