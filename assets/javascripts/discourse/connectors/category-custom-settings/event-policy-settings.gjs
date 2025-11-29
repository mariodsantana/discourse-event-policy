import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import withEventValue from "discourse/helpers/with-event-value";
import { eq } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

/**
 * @component EventPolicySettings
 * Category settings connector for configuring event policies
 */
export default class EventPolicySettings extends Component {
  static shouldRender(args, { siteSettings }) {
    return siteSettings.event_policy_enabled;
  }

  get category() {
    return this.args.outletArgs.category;
  }

  get policyOptions() {
    return [
      { value: "allow", name: i18n("event_policy.policy_options.allow") },
      { value: "require", name: i18n("event_policy.policy_options.require") },
      {
        value: "disallow",
        name: i18n("event_policy.policy_options.disallow"),
      },
    ];
  }

  get firstPostPolicy() {
    return this.category.custom_fields?.event_policy_first_post || "allow";
  }

  get replyPostsPolicy() {
    return this.category.custom_fields?.event_policy_reply_posts || "allow";
  }

  <template>
    <section class="field event-policy-settings">
      <h3>{{i18n "event_policy.category.settings_section"}}</h3>

      <section class="field">
        <label>{{i18n "event_policy.category.event_policy_first_post"}}</label>
        <select
          {{on
            "change"
            (withEventValue
              (fn (mut this.category.custom_fields.event_policy_first_post))
            )
          }}
        >
          {{#each this.policyOptions as |policyOption|}}
            <option
              value={{policyOption.value}}
              selected={{eq this.firstPostPolicy policyOption.value}}
            >
              {{policyOption.name}}
            </option>
          {{/each}}
        </select>
        <div class="setting-help">{{i18n
            "event_policy.category.event_policy_first_post_help"
          }}</div>
      </section>

      <section class="field">
        <label>{{i18n "event_policy.category.event_policy_reply_posts"}}</label>
        <select
          {{on
            "change"
            (withEventValue
              (fn (mut this.category.custom_fields.event_policy_reply_posts))
            )
          }}
        >
          {{#each this.policyOptions as |policyOption|}}
            <option
              value={{policyOption.value}}
              selected={{eq this.replyPostsPolicy policyOption.value}}
            >
              {{policyOption.name}}
            </option>
          {{/each}}
        </select>
        <div class="setting-help">{{i18n
            "event_policy.category.event_policy_reply_posts_help"
          }}</div>
      </section>
    </section>
  </template>
}
