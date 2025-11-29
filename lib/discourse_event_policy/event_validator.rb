# frozen_string_literal: true

module DiscourseEventPolicy
  /**
   * Validates post events against category-level policies
   */
  class EventValidator
    def initialize(post)
      @post = post
    end

    /**
     * Validates that event policy is satisfied for this post
     * Adds errors to post if validation fails
     */
    def validate_event_policy
      return if @post.topic.blank?

      has_event = @post.raw.include?("[event")
      return if !has_event

      category = @post.topic.category
      return if category.blank?

      if @post.is_first_post?
        validate_first_post_policy(category, has_event)
      else
        validate_reply_post_policy(category, has_event)
      end
    end

    private

    def validate_first_post_policy(category, has_event)
      policy = category.custom_fields["event_policy_first_post"] || DiscourseEventPolicy::POLICY_ALLOW

      case policy
      when DiscourseEventPolicy::POLICY_DISALLOW
        @post.errors.add(:base, I18n.t("discourse_event_policy.errors.first_post_events_not_allowed"))
      when DiscourseEventPolicy::POLICY_REQUIRE
        # If policy is require, event must be present (already satisfied by has_event check)
        nil
      when DiscourseEventPolicy::POLICY_ALLOW
        # Allow means no restriction
        nil
      end
    end

    def validate_reply_post_policy(category, has_event)
      policy = category.custom_fields["event_policy_reply_posts"] || DiscourseEventPolicy::POLICY_ALLOW

      case policy
      when DiscourseEventPolicy::POLICY_DISALLOW
        @post.errors.add(:base, I18n.t("discourse_event_policy.errors.reply_post_events_not_allowed"))
      when DiscourseEventPolicy::POLICY_REQUIRE
        # If policy is require, event must be present (already satisfied by has_event check)
        nil
      when DiscourseEventPolicy::POLICY_ALLOW
        # Allow means no restriction
        nil
      end
    end
  end
end
