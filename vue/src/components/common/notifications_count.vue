<script lang="js">
import Records from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import Flash from '@/shared/services/flash';

export default {
  props: {
    model: Object,
    excludeMembers: Boolean,
    includeActor: Boolean
  },

  data() {
    return {count: null, requestSequence: 0};
  },

  mounted() {
    this.updateCount();
  },

  methods: {
    updateCount() {
      const sequence = ++this.requestSequence;
      this.count = null;
      const excludeMembers = (this.excludeMembers && {exclude_members: 1}) || {};
      Records.remote.fetch({path: 'announcements/count', params: {
        recipient_emails_cmr: this.model.recipientEmails.join(','),
        recipient_user_xids: this.model.recipientUserIds.join('x'),
        recipient_chatbot_xids: this.model.recipientChatbotIds.join('x'),
        recipient_audience: this.model.recipientAudience,
        include_actor: (this.includeActor && 1) || null,
        ...this.model.bestNamedId(),
        ...excludeMembers
      }}).then(data => {
        if (sequence === this.requestSequence) this.count = data.count;
      }).catch(error => {
        if (sequence === this.requestSequence) {
          this.count = null;
          Flash.fromServer(error.flash || error);
        }
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
p.common-notifications-count.text-medium-emphasis.text-body-small.mb-0(v-if="count !== null")
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
