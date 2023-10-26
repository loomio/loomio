<script lang="js">
import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';
import Flash from '@/shared/services/flash';
import RecipientsAutocomplete from '@/components/common/recipients_autocomplete';
import StanceService from '@/shared/services/stance_service';
import {map, debounce, without, filter, uniq, uniqBy, some, find, compact} from 'lodash';

export default {
  components: {
    RecipientsAutocomplete
  },

  props: {
    poll: Object
  },

  data() {
    return {
      users: [],
      userIds: [],
      isMember: {},
      isMemberAdmin: {},
      isStanceAdmin: {},
      reset: false,
      saving: false,
      loading: false,
      initialRecipients: [],
      actionNames: [],
      service: StanceService,
      query: ''
    };
  },

  computed: {
    wipOrEmpty() { if (this.poll.closingAt) { return ''; } else { return 'wip_'; } },
    someRecipients() {
      return this.poll.recipientAudience ||
      this.poll.recipientUserIds.length ||
      this.poll.recipientEmails.length ||
      this.poll.recipientChatbotIds.length;
    }
  },

  methods: {
    submit() {
      this.saving = true;
      Records.remote.post(`polls/${this.poll.id}/remind`, {
        poll: {
          recipient_audience: this.poll.recipientAudience,
          recipient_user_ids: this.poll.recipientUserIds,
          recipient_chatbot_ids: this.poll.recipientChatbotIds,
          recipient_message: this.poll.recipientMessage
        }
      }).then(data => {
        const {
          count
        } = data;
        Flash.success('announcement.flash.success', { count });
        EventBus.$emit('closeModal');
      }).finally(() => {
        this.saving = false;
      });
    }
  }
};
</script>

<template lang="pug">
.poll-remind
  .pa-4
    .d-flex.justify-space-between
      h1.headline(v-t="'announcement.form.'+wipOrEmpty+'poll_reminder.title'")
      dismiss-modal-button
    recipients-autocomplete(
      existingOnly
      :label="$t('announcement.form.'+wipOrEmpty+'poll_reminder.helptext')"
      :placeholder="$t('announcement.form.placeholder')"
      :model="poll"
      :reset="reset"
      :excludedUserIds="userIds"
      :excludedAudiences="['group', 'discussion_group']"
      :initialRecipients="initialRecipients")

    v-textarea(
      :label="$t('announcement.form.poll_reminder.message_label')"
      :placeholder="$t('announcement.form.poll_reminder.message_placeholder')"
      v-model="poll.recipientMessage")

    .d-flex
      v-spacer
      v-btn.poll-members-form__submit(color="primary" :disabled="!someRecipients" :loading="saving" @click="submit" )
        span(v-t="'common.action.remind'")
</template>
