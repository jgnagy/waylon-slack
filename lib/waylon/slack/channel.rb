# frozen_string_literal: true

module Waylon
  module Slack
    # A representation of Slack channels for Waylon
    class Channel
      attr_reader :id

      # Allows finding a channel based on its channel name
      # @raise [Slack::Web::Api::Errors::ChannelNotFound] When the channel doesn't exist
      # @return [Channel]
      def self.from_name(name)
        name = "##{name}" unless name.start_with?("#")
        raw = sense.client.conversations_info(channel: name)
        new(raw["channel"]["id"], data: raw["channel"])
      end

      # Provides direct access to the Sense class
      # @return [Class]
      def self.sense
        ::Waylon::Senses::Slack
      end

      def initialize(id = nil, data: {})
        raise "Must provide ID or details" unless id || !data.empty?

        @id = id || data["id"]
        # @data should never be accessed directly... always use the wrapper instance method
        @data = data
      end

      # Is channel archived (meaning no further messages are possible)?
      # @return [Boolean]
      def archived?
        data["is_archived"].dup
      end

      # Provides lazy, cached access to the Channel's internal details
      # @return [Hash]
      def data
        if !@data || @data.empty?
          # Only cache channel info for 5 min
          sense.cache("channels.#{id}", expires: 300) do
            raw_data = sense.client.conversations_info(channel: id)
            @data = raw_data["channel"]
          end
        else
          @data
        end
      end

      # Is this the "main" channel for this team?
      # @return [Boolean]
      def general?
        data["is_general"].dup
      end

      # Lists channel members
      # @return [Array<User>] channel members
      def members
        # Only cache channel member ids for 5 min
        ids = sense.cache("channels.#{id}.member_ids", expires: 300) do
          member_ids = []
          sense.client.conversations_members(channel: id) do |raw|
            member_ids += raw["members"]
          end
          member_ids.sort.uniq
        end
        ids.map { |m| User.new(m) }
      end

      # Is this bot a member of the channel?
      # @return [Boolean]
      def member?
        data["is_member"]
      end

      # The proper channel name
      # @return [String]
      def name
        "##{data["name"]}"
      end

      # Posts a message to a channel
      # @param text [String] Message text or fallback text for blocks
      # @param attachments [Array<Hash>] Old-style message attachments
      # @param blocks [Array<Hash>] New-style block method of sending complex messages
      # @param thread [Integer] The message timestamp for the thread id
      # @return [void]
      def post(text: nil, attachments: nil, blocks: nil, thread: nil)
        options = { channel: id }
        options[:text] = text if text
        options[:attachments] = attachments if attachments
        options[:blocks] = blocks if blocks
        options[:thread_ts] = thread if thread
        sense.client.chat_postMessage(options)
      end

      # Is this a private channel? (meaning a direct message, NOT private in the Slack sense)
      # @return [Boolean]
      def private?
        data["is_im"].dup
      end

      # An instance-level helper to access the class-level method
      # @return [Class]
      def sense
        self.class.sense
      end

      # Provides access to the Channel's topic
      # @return [String]
      def topic
        data.dig("topic", "value").dup
      end
    end
  end
end
