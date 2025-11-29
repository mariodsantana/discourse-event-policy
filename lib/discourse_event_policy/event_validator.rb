# frozen_string_literal: true

module DiscourseEventPolicy
  # Validates post events against category-level policies
  class EventValidator
    def initialize(post)
      @post = post
    end

    # Validates that event policy is satisfied for this post
    # Adds errors to post if validation fails
    def validate_event_policy
      return if @post.topic.blank?

      category = @post.topic.category
      return if category.blank?

      # Use proper event detection from discourse-calendar
      has_event = DiscoursePostEvent::EventParser.extract_events(@post).present?

      if @post.is_first_post?
        validate_first_post_policy(category, has_event)
      else
        validate_reply_post_policy(category, has_event)
      end
    end

    private

    def validate_first_post_policy(category, has_event)
      policy =
        category.custom_fields["event_policy_first_post"] || DiscourseEventPolicy::POLICY_ALLOW

      case policy
      when DiscourseEventPolicy::POLICY_DISALLOW
        if has_event
          @post.errors.add(
            :base,
            I18n.t("discourse_event_policy.errors.first_post_events_not_allowed"),
          )
        end
      when DiscourseEventPolicy::POLICY_REQUIRE
        unless has_event
          @post.errors.add(:base, I18n.t("discourse_event_policy.errors.first_post_event_required"))
        end
      end
    end

    def validate_reply_post_policy(category, has_event)
      policy =
        category.custom_fields["event_policy_reply_posts"] || DiscourseEventPolicy::POLICY_ALLOW

      case policy
      when DiscourseEventPolicy::POLICY_DISALLOW
        if has_event
          @post.errors.add(
            :base,
            I18n.t("discourse_event_policy.errors.reply_post_events_not_allowed"),
          )
        end
      when DiscourseEventPolicy::POLICY_REQUIRE
        unless has_event
          @post.errors.add(:base, I18n.t("discourse_event_policy.errors.reply_post_event_required"))
        end
      end
    end
  end
end
