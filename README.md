# Discourse Event Policy

A Discourse plugin that controls event creation policies per category for the [discourse-calendar plugin](https://github.com/discourse/discourse/tree/main/plugins/discourse-calendar).

## Overview

This plugin allows administrators to configure event creation policies for each category, controlling whether events are:

- **Allowed** (optional) - Users can create events, but don't have to
- **Required** (mandatory) - Posts in this category must include an event
- **Disallowed** (not permitted) - Events cannot be created in this category

Policies can be configured separately for:
1. **First Post** - The opening post of a topic
2. **Reply Posts** - All subsequent posts in a topic

## Requirements

- Discourse (latest)
- [discourse-calendar plugin](https://github.com/discourse/discourse/tree/main/plugins/discourse-calendar)

## Installation

1. Add the plugin to your `app.yml`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home
        cmd: git clone https://github.com/discourse/discourse.git --depth 1 plugins/discourse-event-policy
```

2. Rebuild your container:

```bash
./launcher rebuild app
```

## Configuration

### Site Settings

- **event_policy_enabled** - Enable/disable the plugin (default: true)

### Category Settings

Each category has two new settings available:

1. **Event Policy - First Post** (`event_policy_first_post`)
   - Controls whether events are allowed/required/disallowed in topic opening posts
   - Options: Allow, Require, Disallow
   - Default: Allow

2. **Event Policy - Reply Posts** (`event_policy_reply_posts`)
   - Controls whether events are allowed/required/disallowed in reply posts
   - Options: Allow, Require, Disallow
   - Default: Allow

### Managing Category Settings

To configure event policies for a category:

1. Visit the category settings (Admin > Categories > Edit Category)
2. Scroll to the "Event Policy" section
3. Select the desired policy for first posts and reply posts
4. Save changes

## Policy Behaviors

### Allow (Optional)
- Users can create posts with or without events
- No validation is performed
- This is the default for all categories

### Require (Mandatory)
- Posts must include an event using `[event]` syntax
- Users will see an error if they try to create a post without an event
- Applies only to posts in categories with this policy configured

### Disallow (Not Permitted)
- Posts cannot include events
- Users will see an error if they try to create a post with an event
- Useful for categories where events don't make sense (e.g., announcements)

## How It Works

When a user creates or edits a post, the plugin:

1. Checks if the post's category has event policies configured
2. Determines if the post is a first post or reply
3. Applies the appropriate policy validation
4. Detects if the post contains an event (looks for `[event...]` syntax)
5. Validates against the policy and returns errors if validation fails

The validation integrates with Discourse's post validation system, so policy violations are caught before posts are saved.

## Compatibility

- **discourse-calendar**: Required for event functionality
- Works with the `[event]` syntax from discourse-calendar
- Does not interfere with other calendar functionality
- No database migrations required

## Troubleshooting

### Settings Don't Appear in Category Admin

- Ensure `event_policy_enabled` site setting is true
- Ensure discourse-calendar plugin is installed and enabled
- Clear browser cache or use incognito window

### Events Still Created When Disallowed

- Verify the category has the policy set to "Disallow"
- Check that posts are in the correct category
- Ensure the plugin is enabled in site settings

### Validation Errors Not Showing

- Check browser console for JavaScript errors
- Verify discourse-post-event is enabled (`discourse_post_event_enabled` setting)
- Confirm the post actually contains event syntax

## Development

### File Structure

```
discourse-event-policy/
├── plugin.rb                 # Main plugin file
├── config/
│   ├── locales/en.yml       # Locale strings
│   └── settings.yml         # Site settings
├── lib/
│   └── discourse_event_policy/
│       ├── engine.rb        # Rails engine
│       └── event_validator.rb # Validation logic
└── README.md                # This file
```

### Testing

The plugin validates event policies when posts are created or edited. Test with:

1. Create a category with "Require" policy for first post
2. Try creating a topic without an event - should fail with error message
3. Create a topic with an event - should succeed
4. Create a category with "Disallow" policy for reply posts
5. Try creating a reply with an event - should fail with error message

### Extending

To add additional policy types or validation logic:

1. Add new policies to `DiscourseEventPolicy::VALID_POLICIES` in `plugin.rb`
2. Update `EventValidator` to handle the new policy type
3. Add locale strings for the new policy messages
4. Update category serializers if needed

## License

Same license as Discourse.

## Support

For issues, questions, or suggestions, please visit the [Discourse Meta discussion](https://meta.discourse.org).
