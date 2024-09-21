<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import { I18n }           from '@/i18n';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import { filter } from 'lodash-es';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [WatchRecords, UrlFor],
  props: {
    discussion: Object
  },
  data() {
    return {
      targetGroup: null,
      availableGroups: [],
      loading: false
    };
  },
  created() {
    this.updateTarget();
    this.watchRecords({
      collections: ['groups', 'memberships'],
      query: store => {
        this.availableGroups = Session.user().groups();
      }
    });
  },
  methods: {
    submit() {
      this.loading = true
      this.discussion.move().then(data => {
        Flash.success('move_thread_form.messages.success', { name: this.discussion.group().name });
        const discussionKey = data.discussions[0].key;
        Records.discussions.findOrFetchById(discussionKey, {}, true).then(discussion => {
          EventBus.$emit('closeModal');
          this.$router.push(`/d/${discussionKey}`);
        });
      }).catch(() => true).finally(() => this.loading = false);
    },

    updateTarget() {
      return this.targetGroup = Records.groups.find(this.discussion.groupId);
    },

    moveThread() {
      if (this.discussion.private && this.targetGroup.privacyIsOpen()) {
        if (confirm(I18n.global.t('move_thread_form.confirm_change_to_private_thread', {groupName: this.targetGroup.name}))) { this.submit(); }
      } else {
        this.submit();
      }
    }
  }
};
</script>
<template lang="pug">
v-card.move-thread-form(:title="$t('move_thread_form.title')")
  submit-overlay(:value='discussion.processing')
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    v-select#group-dropdown.move-thread-form__group-dropdown(
      v-model='discussion.groupId'
      :required='true'
      @change='updateTarget()'
      :items='availableGroups'
      item-value='id'
      item-title='fullName'
      :label="$t('move_thread_form.body')")
  v-card-actions
    v-spacer
    v-btn.move-thread-form__submit(:loading="loading" color="primary" variant="tonal" @click='moveThread()')
      span( v-t="'move_thread_form.confirm'")
</template>
