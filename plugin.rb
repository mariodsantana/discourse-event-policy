# frozen_string_literal: true

# name: discourse-event-policy
# about: Controls event creation policies per category for the discourse-calendar plugin
# version: 1.0.0
# authors: Discourse Team
# url: https://github.com/discourse/discourse-event-policy

enabled_site_setting :event_policy_enabled

module ::DiscourseEventPolicy
  PLUGIN_NAME = "discourse-event-policy"
end

after_initialize do
  require_relative "lib/event_policy_validator"

  # Register category custom fields
  reloadable_patch do
    Category.register_custom_field_type("event_policy_first_post", :string)
    Category.register_custom_field_type("event_policy_reply_posts", :string)
    register_preloaded_category_custom_fields("event_policy_first_post")
    register_preloaded_category_custom_fields("event_policy_reply_posts")
  end

  # Add category custom fields to serializer
  add_to_serializer :basic_category, :event_policy_first_post do
    object.custom_fields["event_policy_first_post"]
  end

  add_to_serializer :basic_category, :event_policy_reply_posts do
    object.custom_fields["event_policy_reply_posts"]
  end

  # Validate posts based on event policy
  validate(:post, :validate_event_policy) do |force = nil|
    return unless SiteSetting.event_policy_enabled
    return unless self.raw_changed? || force

    validator = DiscourseEventPolicy::EventPolicyValidator.new(self)
    validator.validate_event_policy
  end
end
