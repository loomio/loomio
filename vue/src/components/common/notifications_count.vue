<script lang="js">
import Records from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';

export default {
  props: {
    model: Object,
    excludeMembers: Boolean,
    includeActor: Boolean
  },

  data() {
    return {count: 0};
  },

  methods: {
    updateCount() {
      const excludeMembers = (this.excludeMembers && {exclude_members: 1}) || {};
      Records.remote.fetch({path: 'announcements/count', params: {
        recipient_emails_cmr: this.model.recipientEmails.join(','),
        recipient_user_xids: this.model.recipientUserIds.join('x'),
        recipient_chatbot_xids: this.model.recipientChatbotIds.join('x'),
        recipient_usernames_cmr: [],
        recipient_audience: this.model.recipientAudience,
        include_actor: (this.includeActor && 1) || null,
        ...this.model.bestNamedId(),
        ...excludeMembers
      }}).then(data => {
        this.count = data.count;
      });
    }
  },

  watch: {
    'model.recipientEmails': 'updateCount',
    'model.recipientUserIds': 'updateCount',
    'model.recipientAudience': 'updateCount',
    'model.groupId': 'updateCount'
  }
};
</script>

<template lang="pug">
p.common-notifications-count.text--secondary.text-caption
  span(v-if="model.groupId && model.group().membershipsCount < 2" v-t="'announcement.form.group_has_no_members_yet'")
  template(v-else)
    template(v-if="model.notifyRecipients")
      span(v-if="count == 0" v-t="'announcement.form.notified_none'")
      span(v-if="count == 1" v-t="'announcement.form.single_notification'")
      span(v-if="count > 1" v-t="{path: 'announcement.form.multiple_notifications', args: {notified: count}}")
    template(v-else)
      span(v-if="count == 0" v-t="'announcement.form.added_none'")
      span(v-if="count == 1" v-t="'announcement.form.added_singular'")
      span(v-if="count > 1" v-t="{path: 'announcement.form.added', args: {count: count}}")
    space
    span(v-if="model.recipientAudience && !model.anonymous" v-t="'announcement.form.click_group_to_see_individuals'")
</template>
