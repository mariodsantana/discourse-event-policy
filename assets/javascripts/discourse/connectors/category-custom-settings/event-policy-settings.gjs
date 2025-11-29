import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import ComboBox from "discourse/select-kit/components/combo-box";
import { i18n } from "discourse-i18n";

export default class EventPolicySettings extends Component {
  @service siteSettings;

  policyOptions = [
    { id: "allow", name: i18n("discourse_event_policy.policy_options.allow") },
    {
      id: "require",
      name: i18n("discourse_event_policy.policy_options.require"),
    },
    {
      id: "disallow",
      name: i18n("discourse_event_policy.policy_options.disallow"),
    },
  ];

  get firstPostPolicy() {
    return (
      this.args.outletArgs.category.custom_fields?.event_policy_first_post ||
      "allow"
    );
  }

  get replyPostsPolicy() {
    return (
      this.args.outletArgs.category.custom_fields?.event_policy_reply_posts ||
      "allow"
    );
  }

  @action
  onChangeFirstPostPolicy(value) {
    this.args.outletArgs.category.custom_fields.event_policy_first_post = value;
  }

  @action
  onChangeReplyPostsPolicy(value) {
    this.args.outletArgs.category.custom_fields.event_policy_reply_posts =
      value;
  }

  <template>
    {{#if this.siteSettings.event_policy_enabled}}
      <section class="field event-policy-settings">
        <h3>{{i18n "discourse_event_policy.category.settings_section"}}</h3>

        <section class="field">
          <label>
            {{i18n "discourse_event_policy.category.event_policy_first_post"}}
          </label>
          <ComboBox
            @value={{this.firstPostPolicy}}
            @content={{this.policyOptions}}
            @onChange={{this.onChangeFirstPostPolicy}}
            class="event-policy-first-post-select"
          />
        </section>

        <section class="field">
          <label>
            {{i18n "discourse_event_policy.category.event_policy_reply_posts"}}
          </label>
          <ComboBox
            @value={{this.replyPostsPolicy}}
            @content={{this.policyOptions}}
            @onChange={{this.onChangeReplyPostsPolicy}}
            class="event-policy-reply-posts-select"
          />
        </section>
      </section>
    {{/if}}
  </template>
}
