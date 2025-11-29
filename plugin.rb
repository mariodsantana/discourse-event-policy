# frozen_string_literal: true

# name: discourse-event-policy
# about: Control event creation policies per category for the discourse-calendar plugin
# version: 0.1
# author: Discourse
# url: https://github.com/discourse/discourse/tree/main/plugins/discourse-event-policy

enabled_site_setting :event_policy_enabled

module ::DiscourseEventPolicy
  PLUGIN_NAME = "discourse-event-policy"

  # Policy constants
  POLICY_ALLOW = "allow"
  POLICY_REQUIRE = "require"
  POLICY_DISALLOW = "disallow"

  VALID_POLICIES = [POLICY_ALLOW, POLICY_REQUIRE, POLICY_DISALLOW].freeze
end

after_initialize do
  require_relative "lib/discourse_event_policy/engine"
  require_relative "lib/discourse_event_policy/event_validator"

  reloadable_patch do
    # Register category custom fields
    Category.register_custom_field_type("event_policy_first_post", :string)
    Category.register_custom_field_type("event_policy_reply_posts", :string)
    register_preloaded_category_custom_fields("event_policy_first_post")
    register_preloaded_category_custom_fields("event_policy_reply_posts")
  end

  # Add to category serializer
  add_to_serializer :basic_category, :event_policy_first_post do
    object.custom_fields["event_policy_first_post"] || DiscourseEventPolicy::POLICY_ALLOW
  end

  add_to_serializer :basic_category, :event_policy_reply_posts do
    object.custom_fields["event_policy_reply_posts"] || DiscourseEventPolicy::POLICY_ALLOW
  end

  # Validate events on post creation/edit if discourse-post-event is enabled
  if defined?(DiscoursePostEvent)
    validate(:post, :validate_event_policy) do |force = nil|
      return unless SiteSetting.event_policy_enabled
      return unless SiteSetting.discourse_post_event_enabled

      # Only validate if raw changed or forced
      return unless self.raw_changed? || force

      validator = DiscourseEventPolicy::EventValidator.new(self)
      validator.validate_event_policy
    end
  end
end
