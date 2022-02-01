# frozen_string_literal: true

RSpec.describe Waylon::Slack::Channel do
  context "for normal channels" do
    subject do
      data = {
        "id" => "C12345",
        "is_archived" => false,
        "is_channel" => true,
        "is_general" => true,
        "is_member" => true,
        "is_private" => false,
        "is_im" => false,
        "name" => "general",
        "topic" => {
          "value" => "The main channel"
        }
      }
      Waylon::Slack::Channel.new(data: data)
    end

    it "provides the slack channel name" do
      expect(subject.name).to eq("#general")
    end

    it "finds the channel's topic" do
      expect(subject.topic).to eq("The main channel")
    end

    it "determines if a channel is private (based on Waylon's definition)" do
      expect(subject.private?).to be(false)
    end
  end

  context "for private channels" do
    subject do
      data = {
        "id" => "C5678",
        "is_archived" => false,
        "is_channel" => false,
        "is_general" => false,
        "is_group" => true,
        "is_member" => true,
        "is_private" => true,
        "is_im" => false,
        "name" => "special-group",
        "topic" => {
          "value" => "Only for l33t h4x0rs"
        }
      }
      Waylon::Slack::Channel.new(data: data)
    end

    it "provides the slack channel name" do
      expect(subject.name).to eq("#special-group")
    end

    it "finds the channel's topic" do
      expect(subject.topic).to eq("Only for l33t h4x0rs")
    end

    it "determines if a channel is private (based on Waylon's definition)" do
      expect(subject.private?).to be(false)
    end
  end

  context "in chats" do
    subject do
      data = {
        "id" => "D12345",
        "is_im" => true,
        "is_user_deleted" => false,
        "user" => "U1234"
      }
      Waylon::Slack::Channel.new(data: data)
    end

    it "determines if a channel is private (based on Waylon's definition)" do
      expect(subject.private?).to be(true)
    end
  end
end
