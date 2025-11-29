# Discourse Event Policy

A Discourse plugin that controls event creation policies per category for the [discourse-calendar plugin](https://github.com/discourse/discourse/tree/main/plugins/discourse-calendar).

## Overview

This plugin allows administrators to configure event creation policies for each category, controlling whether events are:

- **Allowed** (optional) - Users can create events, but don't have to
- **Required** (mandatory) - Topics in this category must include an event
- **Disallowed** (not permitted) - Events cannot be created in this category

> **Note:** This plugin only controls events in topic opening posts (first posts). The discourse-calendar plugin already disallows events in reply posts.

## Configuration

### Site Settings
- **event_policy_enabled** - Enable/disable the plugin (default: true)

### Category Settings
Each category has a new setting available:

**Event Policy** (`event_policy_first_post`)
- Controls whether events are allowed/required/disallowed in topic opening posts
- Options: Allow, Require, Disallow
- Default: Allow

### Managing Category Settings
To configure event policies for a category:

1. Visit the category settings (Admin > Categories > Edit Category > Settings tab)
2. Scroll to the "Event Policy" section
3. Select the desired policy
4. Save changes

## Policy Behaviors

### Allow (Optional)
- Users can create topics with or without events
- No validation is performed
- This is the default for all categories

### Require (Mandatory)
- Topics must include an event using `[event]` syntax
- Users will see an error if they try to create a topic without an event
- Applies only to topic opening posts in categories with this policy configured

### Disallow (Not Permitted)
- Topics cannot include events
- Users will see an error if they try to create a topic with an event
- Useful for categories where events don't make sense (e.g., announcements)

## How It Works

When a user creates or edits a topic's first post, the plugin:

1. Checks if the post's category has an event policy configured
2. Detects if the post contains an event (looks for `[event...]` syntax)
3. Validates against the policy and returns errors if validation fails

The validation integrates with Discourse's post validation system, so policy violations are caught before posts are saved.

### Testing

The plugin validates event policies when topic opening posts are created or edited. Test with:

1. Create a category with "Require" policy
2. Try creating a topic without an event - should fail with error message
3. Create a topic with an event - should succeed
4. Create a category with "Disallow" policy
5. Try creating a topic with an event - should fail with error message
