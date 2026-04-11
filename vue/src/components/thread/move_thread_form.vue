<script lang="js">
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import { I18n }           from '@/i18n';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [WatchRecords, UrlFor],
  props: {
    topic: Object
  },
  data() {
    return {
      groupId: null,
      availableGroups: [],
      loading: false
    };
  },
  created() {
    this.watchRecords({
      collections: ['groups', 'memberships'],
      query: () => { this.availableGroups = Session.user().groups() }
    });
  },
  methods: {
    submit() {
      this.loading = true
      Records.topics.remote.patchMember(this.topic.id, 'move', { group_id: this.groupId }).then(data => {
        Flash.success('move_discussion_form.messages.success', { name: this.targetGroup().name });
        EventBus.$emit('closeModal');
        const topicable = this.topic.topicable();
        this.$router.push(this.urlFor(topicable));
      }).catch(() => true).finally(() => this.loading = false);
    },

    targetGroup() {
      return Records.groups.find(this.groupId);
    },

    moveThread() {
      if (this.topic.private && this.targetGroup().privacyIsOpen()) {
        if (confirm(I18n.global.t('move_discussion_form.confirm_change_to_private', {groupName: this.targetGroup().name}))) { this.submit(); }
      } else {
        this.submit();
      }
    }
  }
};
</script>
<template lang="pug">
v-card.move-thread-form(:title="$t('move_discussion_form.title')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    v-select#group-dropdown.move-thread-form__group-dropdown(
      v-model='groupId'
      :required='true'
      :items='availableGroups'
      item-value='id'
      item-title='fullName'
      :label="$t('move_discussion_form.body')")
  v-card-actions
    v-spacer
    v-btn.move-thread-form__submit(:disabled="!groupId || topic.groupId == groupId" :loading="loading" color="primary" variant="tonal" @click='moveThread()')
      span( v-t="'move_discussion_form.confirm'")
</template>
