# frozen_string_literal: true

module Waylon
  module Senses
    # The Waylon Sense for interacting with Slack via the Events API
    class Slack < Waylon::Sense
      features %i[blocks private_messages reactions threads]

      # Provides easy access to the Slack Web Client for interacting with the Slack API
      # @return [Slack::Web::Client]
      def self.client
        @client ||= ::Slack::Web::Client.new
      end

      # Takes an incoming request from a webhook and converts it to a usable Waylon Message
      # @param request [Hash,Waylon::Message]
      # @return [Waylon::Message]
      def self.message_from_request(request)
        return request if request.is_a?(message_class)

        if request["type"] == "event_callback" && %w[app_mention message].include?(request.dig("event", "type"))
          # These are typical chat messages
          message_class.new(request["event_id"], request["event"])
        elsif request["type"] == "event_callback"
          log("Support for events of type #{request.dig("event", "type")} not yet implemented")
        end
      end

      # "At-mention" for Slack.
      # @param user [Waylon::User] The User to mention
      # @return [String]
      def self.mention(user)
        "<@#{user.handle}>"
      end

      # Provides a simple means to privately reply to the author of a Message
      # @param request [Hash,Waylon::Message]
      # @param text [String] Reply contents
      # @return [void]
      def self.private_reply(request, text)
        message = message_from_request(request)
        message.author.dm(text:)
      end

      # Provides a simple means to privately reply to the author of a Message using Blocks
      # @param request [Hash,Waylon::Message]
      # @param blocks [Array] Blocks data to reply with
      # @return [void]
      def self.private_reply_with_blocks(request, blocks)
        message = message_from_request(request)
        message.author.dm(blocks:)
      end

      # Allows reacting to a request via the Sense's own mechanism
      # @param request [Hash,Waylon::Message]
      # @param reaction [String]
      # @return [void]
      def self.react(request, reaction)
        message = message_from_request(request)
        message.react(reaction)
      end

      # Reply to a Message in a Channel with some text
      # @param request [Hash,Waylon::Message]
      # @param text [String] Reply contents
      # @return [void]
      def self.reply(request, text)
        message = message_from_request(request)
        message.channel.post(text:)
      end

      # Reply to a Message in a Channel with some blocks
      # @param request [Hash,Waylon::Message]
      # @param blocks [Array] Blocks to reply with
      # @return [void]
      def self.reply_with_blocks(request, blocks)
        message = message_from_request(request)
        message.channel.post(blocks:)
      end

      # Executed by Resque, this is how this Sense determines what to do with an incoming request
      # @param received_web_content [Hash] The parsed web request content from the Webhook
      # @return [void]
      def self.run(received_web_content)
        log("Received request of type #{received_web_content["type"]}", :debug)
        message = message_from_request(received_web_content)
        unless message
          log("Unable to handle request")
          return
        end

        if message.author == Waylon::Slack::User.whoami
          log("Ignoring my own message...", :debug)
          return
        end

        log("Responding to message from bot '#{message.author.handle}'") if message.author.bot?

        route = Waylon::SkillRegistry.route(message) || SkillRegistry.instance.default_route(message)
        enqueue(route, received_web_content)
      end

      # Reply to a Message in a Thread with some text
      # @param request [Hash,Waylon::Message]
      # @param text [String] Reply contents
      # @return [void]
      def self.threaded_reply(request, text)
        message = message_from_request(request)
        message.channel.post(text:, thread: message.thread_parent)
      end

      # Required by the Waylon framework, this provides the Sense's own Message class
      # @return [Class]
      def self.message_class
        Waylon::Slack::Message
      end

      # Required by the Waylon framework, this provides the Sense's own User class
      # @return [Class]
      def self.user_class
        Waylon::Slack::User
      end

      # Automatically informs Waylon about this Sense
      SenseRegistry.register(:slack, self)
    end
  end
end
