# frozen_string_literal: true

RSpec.describe Waylon::Slack::Channel do
  context "sent in normal channels" do
    let(:a_mention_request) do
      {
        "event" => {
          "channel" => chatroom.id.to_s,
          "text" => "@#{bot.id} I'm mentioning you",
          "ts" => "1234567.89",
          "type" => "app_mention",
          "user" => testuser.id.to_s
        },
        "event_id" => "ABC123",
        "type" => "event_callback"
      }
    end

    subject do
      Waylon::Senses::Slack.message_from_request(a_mention_request)
    end

    before(:each) do
      allow(Waylon::Slack::User).to receive(:whoami) { bot }
    end

    it "identifies the author of messages" do
      expect(subject.author).to be_a(Waylon::User)
      expect(subject.author.id.to_s).to eq(testuser.id.to_s)
    end

    it "provides the channel in which it was sent" do
      expect(subject.channel.id.to_s).to eq(chatroom.id.to_s)
    end

    it "identifies when a message mentions the bot" do
      expect(subject.mentions_bot?).to be_truthy
    end

    it "can tell if a message is part of a thread" do
      expect(subject.part_of_thread?).not_to be_truthy
    end

    it "provides sanitized message text" do
      expect(subject.body).to eq("I'm mentioning you")
    end

    it "identifies thread parents (when applicable)" do
      expect(subject.thread_parent).to eq("1234567.89")
    end

    it "identifies when a message is directed at the bot (vs someone else or nobody)" do
      expect(subject.to_bot?).to be_truthy
    end

    it "provides the 'ts' value for the message" do
      expect(subject.ts).to eq("1234567.89")
    end
  end
end
