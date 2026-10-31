<script lang="js">
import Flash   from '@/shared/services/flash';
import { useI18n } from 'vue-i18n';
export default {
  setup() {
    const { t } = useI18n();
    return { t };
  },
  props: {
    topic: Object,
    close: Function
  },
  data() {
    return {clone: this.topic.clone()};
  },
  methods: {
    submit() {
      this.clone.save().then(() => {
        this.close();
        Flash.success("discussion_form.messages.updated");
      });
    }
  }
};
</script>

<template lang="pug">
v-card.topic-arrangement-form(:title="$t('thread_arrangement_form.thread_settings')")
  template(v-slot:append)
    help-btn.text-medium-emphasis.mr-2(path="en/user_manual/discussions/using_discussions#thread-settings" variant="text")
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    .text-body-large.pb-2(v-t="'thread_arrangement_form.layout'")
    v-radio-group(v-model="clone.maxDepth")
      v-radio(:value="1")
        template(v-slot:label)
          strong {{ t('activity_card.chronological') }}
          | &nbsp;—&nbsp;
          span(v-t="'thread_arrangement_form.timeline_description'")
      v-radio(:value="3")
        template(v-slot:label)
          strong {{ t('activity_card.nested') }}
          | &nbsp;—&nbsp;
          span(v-t="'thread_arrangement_form.threaded_description'")
    v-alert.mb-2(density="compact" variant="tonal" type="info" v-if="clone.maxDepth != topic.maxDepth")
      span(v-t="'thread_arrangement_form.for_everyone'")
    topic-settings-fields(:model="clone" :kind="topic.topicableType === 'Poll' ? 'poll' : 'discussion'")
  v-card-actions
    v-spacer
    v-btn(color="primary" variant="elevated" @click="submit()" :loading="clone.processing")
      span(v-t="'common.action.save'")
</template>
