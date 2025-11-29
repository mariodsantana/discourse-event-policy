/* eslint-disable ember/no-classic-components */
import Component from "@ember/component";
import { action } from "@ember/object";
import { tagName } from "@ember-decorators/component";
import ComboBox from "discourse/select-kit/components/combo-box";
import { i18n } from "discourse-i18n";

@tagName("")
export default class EventPolicySettings extends Component {
  get policyOptions() {
    return [
      {
        id: "allow",
        name: i18n("discourse_event_policy.policy_options.allow"),
      },
      {
        id: "require",
        name: i18n("discourse_event_policy.policy_options.require"),
      },
      {
        id: "disallow",
        name: i18n("discourse_event_policy.policy_options.disallow"),
      },
    ];
  }

  get firstPostPolicy() {
    return this.category?.custom_fields?.event_policy_first_post || "allow";
  }

  get replyPostsPolicy() {
    return this.category?.custom_fields?.event_policy_reply_posts || "allow";
  }

  @action
  onChangeFirstPostPolicy(value) {
    this.category.custom_fields.event_policy_first_post = value;
  }

  @action
  onChangeReplyPostsPolicy(value) {
    this.category.custom_fields.event_policy_reply_posts = value;
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
