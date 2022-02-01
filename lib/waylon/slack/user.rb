# frozen_string_literal: true

module Waylon
  module Slack
    # A representation of Slack users for Waylon
    class User
      include Waylon::User

      # Find a Slack User based on their IM handle
      # @param handle [String]
      # @return [User]
      def self.find_by_handle(handle)
        real_handle = handle.start_with?("@") ? handle : "@#{handle}"
        from_response(sense.client.users_info(user: real_handle))
      end

      # Find a Slack User based on their email address
      # @param email [String]
      # @return [User]
      # @note Not recommended as it requires an additional scope on the OAuth token
      def self.find_by_email(email)
        from_response(sense.client.users_lookupByEmail(email))
      end

      # Find a Slack User based on the text provided by Slack from a mention of that User
      # @param mention_string [String]
      # @return [User]
      def self.from_mention(mention_string)
        from_response(sense.client.users_info(user: mention_string[1..]))
      end

      # Provide a Slask User based on a Web API response
      # @param response [Hash] The response from a Web API request
      # @return [User]
      def self.from_response(response)
        raise "Failed Request" unless response && response["ok"]

        new(data: response["user"])
      end

      # Allows easy access to the Sense class
      # @return [Class]
      def self.sense
        ::Waylon::Senses::Slack
      end

      # A convenient way use the Slack API to figure out the bot's own info
      # @return [User]
      def self.whoami
        response = sense.cache("whoami") { sense.client.auth_test }
        new(response["user_id"])
      end

      def initialize(id = nil, data: {})
        raise "Must provide ID or details" unless id || !data.empty?

        @id = id || data["id"]
        @data = data
      end

      # Provides lazy, cached access to the User's internal details
      # @return [Hash]
      def data
        if !@data || @data.empty?
          sense.cache("users.#{id}") do
            raw_data = sense.client.users_info(user: id)
            @data = raw_data["user"]
          end
        else
          @data
        end
      end

      # Is this user a bot?
      # @return [Boolean]
      def bot?
        data["is_bot"]
      end

      # Posts a direct (private) message to a user
      # @param text [String] Message text or fallback text for blocks
      # @param attachments [Array<Hash>] Old-style message attachments
      # @param blocks [Array<Hash>] New-style block method of sending complex messages
      # @param thread [Integer] The message timestamp for the thread id
      # @return [void]
      def dm(text: nil, attachments: nil, blocks: nil, thread: nil)
        options = { channel: id } # Sends a message to the user's ID
        options[:text] = text if text
        options[:attachments] = attachments if attachments
        options[:blocks] = blocks if blocks
        options[:thread_ts] = thread if thread
        sense.client.chat_postMessage(options)
      end

      # The User's email address
      # @return [String]
      def email
        profile["email"]
      end

      # The User's username/chat handle
      # @return [String]
      def handle
        bot? ? data["real_name"] : data["name"]
      end

      # The User's profile information
      # @return [Slack::Messages::Message]
      def profile
        data["profile"]
      end

      # Easy access to the Sense class
      # @return [Class]
      def sense
        self.class.sense
      end

      # The User's current Status (comes from cache so can be outdated)
      # @return [String]
      def status
        profile["status_text"]
      end

      # The User's Slack team ID
      # @return [String]
      def team
        data["team_id"]
      end

      # The User's time zone
      # @return [String]
      def tz
        data["tz"]
      end
    end
  end
end
