# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscourseEventPolicy::EventPolicyValidator do
  fab!(:user)
  fab!(:category)

  before { SiteSetting.event_policy_enabled = true }

  describe "#validate_event_policy" do
    context "when policy is set to 'allow'" do
      before do
        category.custom_fields["event_policy_first_post"] = "allow"
        category.save!
      end

      it "allows posts with events" do
        topic = Fabricate(:topic, category: category)
        post = Fabricate.build(:post, user: user, topic: topic, raw: "[event start=\"2025-12-01\"]")
        validator = described_class.new(post)

        expect(validator.validate_event_policy).to eq(true)
        expect(post.errors).to be_empty
      end

      it "allows posts without events" do
        topic = Fabricate(:topic, category: category)
        post = Fabricate.build(:post, user: user, topic: topic, raw: "Just a regular post")
        validator = described_class.new(post)

        expect(validator.validate_event_policy).to eq(true)
        expect(post.errors).to be_empty
      end
    end

    context "when policy is set to 'require'" do
      before do
        category.custom_fields["event_policy_first_post"] = "require"
        category.save!
      end

      it "allows first posts with events" do
        topic = Fabricate(:topic, category: category)
        post = Fabricate.build(:post, user: user, topic: topic, raw: "[event start=\"2025-12-01\"]")
        validator = described_class.new(post)

        expect(validator.validate_event_policy).to eq(true)
        expect(post.errors).to be_empty
      end

      it "rejects first posts without events" do
        topic = Fabricate(:topic, category: category)
        post = Fabricate.build(:post, user: user, topic: topic, raw: "Just a regular post")
        validator = described_class.new(post)

        expect(validator.validate_event_policy).to eq(false)
        expect(post.errors[:base]).to include(I18n.t("event_policy.errors.event_required"))
      end

      it "does not apply to reply posts" do
        topic = Fabricate(:topic, category: category)
        Fabricate(:post, topic: topic)
        reply = Fabricate.build(:post, user: user, topic: topic, raw: "Reply without event")
        validator = described_class.new(reply)

        expect(validator.validate_event_policy).to eq(true)
        expect(reply.errors).to be_empty
      end
    end

    context "when policy is set to 'disallow'" do
      before do
        category.custom_fields["event_policy_first_post"] = "disallow"
        category.save!
      end

      it "allows first posts without events" do
        topic = Fabricate(:topic, category: category)
        post = Fabricate.build(:post, user: user, topic: topic, raw: "Just a regular post")
        validator = described_class.new(post)

        expect(validator.validate_event_policy).to eq(true)
        expect(post.errors).to be_empty
      end

      it "rejects first posts with events" do
        topic = Fabricate(:topic, category: category)
        post = Fabricate.build(:post, user: user, topic: topic, raw: "[event start=\"2025-12-01\"]")
        validator = described_class.new(post)

        expect(validator.validate_event_policy).to eq(false)
        expect(post.errors[:base]).to include(I18n.t("event_policy.errors.event_not_allowed"))
      end

      it "does not apply to reply posts" do
        topic = Fabricate(:topic, category: category)
        Fabricate(:post, topic: topic)
        reply =
          Fabricate.build(:post, user: user, topic: topic, raw: "[event start=\"2025-12-01\"]")
        validator = described_class.new(reply)

        expect(validator.validate_event_policy).to eq(true)
        expect(reply.errors).to be_empty
      end
    end

    context "when the plugin is disabled" do
      before { SiteSetting.event_policy_enabled = false }

      it "does not enforce any policy" do
        category.custom_fields["event_policy_first_post"] = "require"
        category.save!
        topic = Fabricate(:topic, category: category)
        post = Fabricate.build(:post, user: user, topic: topic, raw: "No event here")

        expect(post.save).to eq(true)
        expect(post.errors).to be_empty
      end
    end

    context "when post has no category" do
      it "does not enforce any policy" do
        topic = Fabricate(:topic, category: nil)
        post = Fabricate.build(:post, user: user, topic: topic, raw: "No event here")
        validator = described_class.new(post)

        expect(validator.validate_event_policy).to eq(true)
        expect(post.errors).to be_empty
      end
    end

    context "when post has no topic" do
      it "does not enforce any policy" do
        post = Fabricate.build(:post, user: user, raw: "No event here")
        post.topic = nil
        validator = described_class.new(post)

        expect(validator.validate_event_policy).to eq(true)
        expect(post.errors).to be_empty
      end
    end
  end

  describe "#post_contains_event?" do
    it "detects event syntax with various formats" do
      post = Fabricate.build(:post, raw: "[event start=\"2025-12-01\"]")
      validator = described_class.new(post)

      expect(validator.send(:post_contains_event?)).to eq(true)
    end

    it "detects event syntax with additional parameters" do
      post = Fabricate.build(:post, raw: "[event start=\"2025-12-01\" end=\"2025-12-02\"]")
      validator = described_class.new(post)

      expect(validator.send(:post_contains_event?)).to eq(true)
    end

    it "returns false when no event syntax is present" do
      post = Fabricate.build(:post, raw: "This is just a regular post with no event")
      validator = described_class.new(post)

      expect(validator.send(:post_contains_event?)).to eq(false)
    end

    it "returns false for the word 'event' without syntax" do
      post = Fabricate.build(:post, raw: "Let's talk about the event happening tomorrow")
      validator = described_class.new(post)

      expect(validator.send(:post_contains_event?)).to eq(false)
    end
  end

  describe "#first_post?" do
    it "returns true when post_number is 1" do
      topic = Fabricate(:topic, category: category)
      post = Fabricate.build(:post, topic: topic, post_number: 1)
      validator = described_class.new(post)

      expect(validator.send(:first_post?)).to eq(true)
    end

    it "returns false when post_number is greater than 1" do
      topic = Fabricate(:topic, category: category)
      post = Fabricate.build(:post, topic: topic, post_number: 2)
      validator = described_class.new(post)

      expect(validator.send(:first_post?)).to eq(false)
    end

    it "returns true when post_number is nil and topic has no posts" do
      topic = Fabricate(:topic, category: category)
      topic.update_column(:posts_count, 0)
      post = Fabricate.build(:post, topic: topic)

      validator = described_class.new(post)

      expect(validator.send(:first_post?)).to eq(true)
    end

    it "returns false when post_number is nil and topic has posts" do
      topic = Fabricate(:topic, category: category)
      Fabricate(:post, topic: topic)
      post = Fabricate.build(:post, topic: topic)

      validator = described_class.new(post)

      expect(validator.send(:first_post?)).to eq(false)
    end
  end
end
