# frozen_string_literal: true

module Waylon
  module Webhooks
    # Webhook for the Slack Sense for Waylon
    class Slack < Waylon::Webhook
      before do
        content_type "application/json"
      end

      post "/" do
        request.body.rewind
        verify(request) unless ENV.fetch("LOCAL_MODE", false)
        if @parsed_body.is_a?(Hash) && @parsed_body[:type] == "url_verification"
          { challenge: @parsed_body[:challenge] }.to_json
        else
          enqueue(@parsed_body)
          { status: :ok }.to_json
        end
      rescue ::Slack::Events::Request::InvalidSignature, ::Slack::Events::Request::TimestampExpired
        halt(403, { error: "Unable to authenticate request" }.to_json)
      rescue StandardError => e
        log("Encountered #{e.message}", :warn)
        halt(422, { error: "Unprocessable entity: #{e.message}" }.to_json)
      end

      options "/" do
        halt 200
      end

      # Used to verify incoming Slack requests
      def verify(incoming_request)
        slack_request = ::Slack::Events::Request.new(incoming_request)
        slack_request.verify!
      end

      # Automatically informs Waylon about this Webhook
      Waylon::WebhookRegistry.register(:slack, self)
    end
  end
end
