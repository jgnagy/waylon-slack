# frozen_string_literal: true

RSpec.describe Waylon::Slack::User do
  context "for human users" do
    let(:a_human_response) do
      {
        "ok" => true,
        "user" => {
          "id" => "W012A3CDE",
          "team_id" => "T012AB3C4",
          "name" => "spengler",
          "deleted" => false,
          "color" => "9f69e7",
          "real_name" => "Egon Spengler",
          "tz" => "America/New_York",
          "tz_label" => "Eastern Daylight Time",
          "tz_offset" => -14_400,
          "profile" => {
            "title" => "",
            "phone" => "",
            "skype" => "",
            "real_name" => "Egon Spengler",
            "real_name_normalized" => "Egon Spengler",
            "display_name" => "spengler",
            "display_name_normalized" => "spengler",
            "status_text" => "Print is dead",
            "status_emoji" => ":books:",
            "status_expiration" => 1_502_138_999,
            "avatar_hash" => "ge3b51ca72de",
            "first_name" => "Matthew",
            "last_name" => "Johnston",
            "email" => "spengler@ghostbusters.example.com",
            "team" => "T012AB3C4"
          },
          "is_admin" => true,
          "is_owner" => false,
          "is_primary_owner" => false,
          "is_restricted" => false,
          "is_ultra_restricted" => false,
          "is_bot" => false,
          "is_stranger" => false,
          "updated" => 1_502_138_686,
          "is_app_user" => false,
          "is_invited_user" => false,
          "has_2fa" => false,
          "locale" => "en-US"
        }
      }
    end

    subject do
      Waylon::Slack::User.from_response(a_human_response)
    end

    it "can tell bot users from human users" do
      expect(subject.bot?).not_to be_truthy
    end

    it "determines user emails" do
      expect(subject.email).to eq("spengler@ghostbusters.example.com")
    end

    it "determines user handles" do
      expect(subject.handle).to eq("spengler")
    end

    it "provides the user's status" do
      expect(subject.status).to eq("Print is dead")
    end

    it "provides the user's team ID" do
      expect(subject.team).to eq("T012AB3C4")
    end

    it "provides the user's timezone" do
      expect(subject.tz).to eq("America/New_York")
    end
  end
end
