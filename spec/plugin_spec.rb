# frozen_string_literal: true

require "rails_helper"

describe DiscourseEventPolicy do
  fab!(:user)
  fab!(:category)

  before { SiteSetting.event_policy_enabled = true }

  describe "post validation integration" do
    it "validates first posts with 'require' policy" do
      category.custom_fields["event_policy_first_post"] = "require"
      category.save!

      topic = Fabricate(:topic, category: category)
      post = Fabricate.build(:post, user: user, topic: topic, raw: "No event here")

      expect(post.save).to eq(false)
      expect(post.errors[:base]).to include(I18n.t("event_policy.errors.event_required"))
    end

    it "allows first posts with events when policy is 'require'" do
      category.custom_fields["event_policy_first_post"] = "require"
      category.save!

      topic = Fabricate(:topic, category: category)
      post = Fabricate.build(:post, user: user, topic: topic, raw: "[event start=\"2025-12-01\"]")

      expect(post.save).to eq(true)
      expect(post.errors).to be_empty
    end

    it "validates first posts with 'disallow' policy" do
      category.custom_fields["event_policy_first_post"] = "disallow"
      category.save!

      topic = Fabricate(:topic, category: category)
      post = Fabricate.build(:post, user: user, topic: topic, raw: "[event start=\"2025-12-01\"]")

      expect(post.save).to eq(false)
      expect(post.errors[:base]).to include(I18n.t("event_policy.errors.event_not_allowed"))
    end

    it "allows first posts without events when policy is 'disallow'" do
      category.custom_fields["event_policy_first_post"] = "disallow"
      category.save!

      topic = Fabricate(:topic, category: category)
      post = Fabricate.build(:post, user: user, topic: topic, raw: "Just a regular post")

      expect(post.save).to eq(true)
      expect(post.errors).to be_empty
    end

    it "does not apply policy to reply posts" do
      category.custom_fields["event_policy_first_post"] = "require"
      category.save!

      topic = Fabricate(:topic, category: category)
      first_post = topic.first_post
      first_post.raw = "[event start=\"2025-12-01\"]"
      first_post.save!

      reply_without_event = Fabricate.build(:post, user: user, topic: topic, raw: "This is fine")
      expect(reply_without_event.save).to eq(true)
    end

    it "correctly identifies first post when post_number is nil during validation" do
      category.custom_fields["event_policy_first_post"] = "require"
      category.save!

      topic = Fabricate(:topic, category: category)
      topic.update_column(:posts_count, 0)

      post = Fabricate.build(:post, user: user, topic: topic, raw: "No event here")
      expect(post.save).to eq(false)
      expect(post.errors[:base]).to include(I18n.t("event_policy.errors.event_required"))
    end
  end

  describe "category custom fields" do
    it "registers event_policy_first_post custom field" do
      expect(Category.custom_field_types).to include("event_policy_first_post" => :string)
    end
  end
end
