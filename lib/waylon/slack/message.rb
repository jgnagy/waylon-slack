# frozen_string_literal: true

module Waylon
  module Slack
    # A representation of Slack messages for Waylon
    class Message
      include Waylon::Message

      attr_reader :id, :data

      def initialize(id, data = {})
        @id = id
        @data = data
      end

      # The User that authored this Message
      # @return [User]
      def author
        User.new(data["user"])
      end

      # The Channel where this Message was sent
      # @return [Channel]
      def channel
        Channel.new(data["channel"])
      end

      # Does the message text mention the bot?
      # @return [Boolean]
      def mentions_bot?
        me = User.whoami
        reg = /(,\s+)?\s*@#{me.id},?\s*/
        ::Slack::Messages::Formatting.unescape(data["text"]) =~ reg ? true : false
      end

      # Is this Message a reply in a thread?
      # @return [Boolean]
      def part_of_thread?
        thread_ts && thread_ts != ts
      end

      # Is this a private Message / direct Message?
      # @return [Boolean]
      def private_message?
        channel.private?
      end

      alias private? private_message?

      # Uses the Sense's Web Client to add a reaction to a Message
      # @param reaction [String,Symbol] The reaction to add (not wrapped in ":")
      # @return [void]
      def react(reaction)
        sense.client.reactions_add(channel: channel.id, name: reaction, timestamp: ts)
      end

      # Easy access to the Sense class
      # @return [Class]
      def sense
        ::Waylon::Senses::Slack
      end

      # The unescaped contents of the Message
      # @return [String]
      def text
        me = User.whoami
        reg = /(,\s+)?\s*@#{me.id},?\s*/
        ::Slack::Messages::Formatting.unescape(data["text"]).gsub(reg, "")
      end

      alias body text

      # The TS value of the parent of this Message's thread, or its own TS if it is the parent
      # @return [String]
      def thread_parent
        thread_ts || ts
      end

      # The TS value of the parent of this Message's thread, if it exists
      # @return [String,nil]
      def thread_ts
        data["thread_ts"].dup
      end

      # Does this Message either directly mention or is it directly to this bot?
      # @return [Boolean]
      def to_bot?
        data["type"] == "app_mention" || private_message?
      end

      # This Message's own TS value (which should not be used for threading if it itself is a thread reply)
      # @return [String]
      def ts
        data["ts"].dup
      end
    end
  end
end
