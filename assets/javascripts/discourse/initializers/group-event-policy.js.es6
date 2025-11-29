import { withPluginApi } from 'discourse/lib/plugin-api';

export default {
  name: 'group-event-policy',
  initialize() {
    withPluginApi('0.8.7', api => {
      api.decorateWidget('group-settings:after', helper => {
        const group = helper.widget.group || helper.widget.model;
        if (!group) { return; }

        const topicValue = group.events_policy_topic || api.container.lookup('site-settings:main').discourse_event_policy_default_topic_policy || 'allow';
        const replyValue = group.events_policy_reply || api.container.lookup('site-settings:main').discourse_event_policy_default_reply_policy || 'allow';

        function saveField(field, value) {
          group.custom_fields = group.custom_fields || {};
          group.custom_fields[field] = value;
          // ensure the group model change is picked up by the admin form
          if (helper.widget.set) { helper.widget.set(`group.custom_fields.${field}`, value); }
        }

        return helper.h('div.event-policy-plugin', [
          helper.h('h4', 'Event Policy'),

          helper.h('label', 'Topic (first post)'),
          helper.h('select', {
            onchange: e => saveField('events_policy_topic', e.target.value),
            value: topicValue
          }, [
            helper.h('option', { value: 'allow' }, 'Allow'),
            helper.h('option', { value: 'require' }, 'Require'),
            helper.h('option', { value: 'disallow' }, 'Disallow')
          ]),

          helper.h('label', 'Replies'),
          helper.h('select', {
            onchange: e => saveField('events_policy_reply', e.target.value),
            value: replyValue
          }, [
            helper.h('option', { value: 'allow' }, 'Allow'),
            helper.h('option', { value: 'require' }, 'Require'),
            helper.h('option', { value: 'disallow' }, 'Disallow')
          ])
        ]);
      });
    });
  }
};
