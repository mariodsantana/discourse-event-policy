# frozen_string_literal: true

module DiscourseEventPolicy
  # Validator for event policy enforcement
  #
  # This class validates that posts adhere to category event policies,
  # enforcing whether events are required, allowed, or disallowed.
  class EventPolicyValidator
    POLICY_ALLOW = "allow"
    POLICY_REQUIRE = "require"
    POLICY_DISALLOW = "disallow"

    # @param post [Post] the post to validate
    def initialize(post)
      @post = post
    end

    # Validates the post against the category's event policy
    #
    # @returns [Boolean] true if validation passes, false otherwise
    def validate_event_policy
      return true unless @post.topic

      category = @post.topic.category
      return true unless category

      policy = get_policy_for_post(category)
      return true unless policy

      has_event = post_contains_event?

      case policy
      when POLICY_REQUIRE
        unless has_event
          @post.errors.add(:base, I18n.t("event_policy.errors.event_required"))
          return false
        end
      when POLICY_DISALLOW
        if has_event
          @post.errors.add(:base, I18n.t("event_policy.errors.event_not_allowed"))
          return false
        end
      end

      true
    end

    private

    # Gets the appropriate policy for the post based on whether it's a first post or reply
    #
    # @param category [Category] the category to check
    # @returns [String, nil] the policy string or nil
    def get_policy_for_post(category)
      is_first_post = first_post?

      policy =
        if is_first_post
          category.custom_fields["event_policy_first_post"]
        else
          category.custom_fields["event_policy_reply_posts"]
        end

      # Only return policy if it's set to something other than "allow" (the default)
      policy if policy.present? && policy != POLICY_ALLOW
    end

    # Determines if the post is a first post (topic opener)
    # During validation of new posts, post_number is nil, so we check if the topic has no posts yet
    #
    # @returns [Boolean] true if this is a first post
    def first_post?
      return true if @post.post_number == 1
      return false if @post.post_number.present?

      # For new posts, post_number is nil - check if topic has no posts yet
      # This handles both new topic creation and the edge case of a topic with 0 posts
      @post.topic&.posts_count.to_i == 0
    end

    # Checks if the post contains event syntax
    #
    # @returns [Boolean] true if the post contains event syntax
    def post_contains_event?
      # Look for [event syntax in the raw post content
      @post.raw.match?(/\[event\s/)
    end
  end
end
