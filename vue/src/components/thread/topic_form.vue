<script lang="js">
import Flash   from '@/shared/services/flash';
export default {
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
v-card.thread-arrangement-form(:title="$t('thread_arrangement_form.thread_settings')")
  template(v-slot:append)
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    p.text-medium-emphasis(v-t="'thread_arrangement_form.layout'")
    v-radio-group(v-model="clone.maxDepth")
      v-radio(:value="1")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.timeline'")
          | &nbsp;—&nbsp;
          span(v-t="'thread_arrangement_form.timeline_description'")
      v-radio(:value="3")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.threaded'")
          | &nbsp;—&nbsp;
          span(v-t="'thread_arrangement_form.threaded_description'")
    v-alert.mb-2(density="compact" variant="tonal" type="info" v-if="clone.maxDepth != topic.maxDepth")
      span(v-t="'thread_arrangement_form.for_everyone'")
    v-checkbox(v-if="topic.topicableType !== 'Poll'" v-model="clone.allowConcurrentPolls" :label="$t('thread_arrangement_form.allow_multiple_polls')" hide-details)
    template(v-if="topic.topicableType === 'Poll'")
      v-checkbox(v-model="clone.allowComments" :label="$t('thread_arrangement_form.allow_comments')" hide-details)
      v-checkbox(v-model="clone.allowReactions" :label="$t('thread_arrangement_form.allow_reactions')" hide-details)
  v-card-actions
    v-spacer
    v-btn(color="primary" variant="elevated" @click="submit()" :loading="clone.processing")
      span(v-t="'common.action.save'")
</template>
