# frozen_string_literal: true

RSpec.describe Waylon::Senses::Slack do
  let(:a_mention_request) do
    {
      "event" => {
        "channel" => "C123456",
        "text" => "@#{bot.id} I'm mentioning you",
        "ts" => "1234567.89",
        "type" => "app_mention",
        "user" => "U234567"
      },
      "event_id" => "ABC123",
      "type" => "event_callback"
    }
  end

  subject { Waylon::Senses::Slack }

  %i[blocks private_messages reactions threads].each do |feature|
    it "supports the '#{feature}' Waylon feature" do
      expect(subject.supports?(feature)).to be(true)
    end
  end

  it "produces Messages from valid request" do
    allow(Waylon::Slack::User).to receive(:whoami) { bot }
    message = subject.message_from_request(a_mention_request)
    expect(message).to be_a(Waylon::Message)
    expect(message).to be_a(Waylon::Slack::Message)
    expect(message.to_bot?).to be(true)
    expect(message.body).to eq("I'm mentioning you")
  end

  it "produces proper mention handles" do
    expect(subject.mention(bot)).to eq("<@waylon>")
  end
end
