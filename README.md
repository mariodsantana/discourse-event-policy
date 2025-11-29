# discourse-event-policy

Small Discourse plugin to enforce per-group event policies for topic first-posts and replies.

Features
- Per-group policy values: `require`, `allow`, `disallow`
- Separate policy for topic first-posts (`events_policy_topic`) and replies (`events_policy_reply`)
- Uses existing event detection when `discourse-post-event` or similar is installed, and falls back to heuristics

Installation
1. Copy the `discourse-event-policy` folder into your Discourse `plugins/` directory.
2. Restart Discourse (unicorn/puma + Sidekiq as usual).

Settings
- The plugin exposes site settings in `config/settings.yml`:
	- `discourse_event_policy_enabled` (boolean) — enable/disable the plugin
	- `discourse_event_policy_default_topic_policy` — default policy for new groups/topics
	- `discourse_event_policy_default_reply_policy` — default policy for replies

These provide global defaults; group-level custom fields (`events_policy_topic` and `events_policy_reply`) override them.

Group settings UI
-----------------
This plugin adds two dropdowns to the Group settings page in the admin UI so you can set per-group policies:

- `Topic (first post)` — `allow` / `require` / `disallow`
- `Replies` — `allow` / `require` / `disallow`

Changing the dropdowns updates the group's `custom_fields` and will be persisted when you save the group.

Configuration (Rails console)
Set a group's policy (valid values: `require`, `allow`, `disallow`):

```ruby
g = Group.find_by(name: "your-group-name")
g.custom_fields["events_policy_topic"] = "require"   # for first/topic posts
g.custom_fields["events_policy_reply"] = "allow"     # for replies
g.save!
```

Behavior
- If any of a user's groups `disallow` events for the context, posts containing events will be rejected.
- If any of a user's groups `require` events for the context, posts lacking an event will be rejected.
- `disallow` takes precedence over `require` when multiple groups apply.

Notes
- By default the plugin checks first posts (topics) vs replies separately.
- The plugin intentionally avoids modifying the calendar/post-event plugin; it simply uses its APIs if present.
