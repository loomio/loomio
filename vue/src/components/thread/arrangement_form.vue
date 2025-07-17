<script lang="js">
import Flash   from '@/shared/services/flash';
export default {
  props: {
    discussion: Object,
    close: Function
  },
  data() {
    return {clone: this.discussion.clone()};
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
v-card.thread-arrangement-form(:title="$t('thread_arrangement_form.title')")
  template(v-slot:append)
    dismiss-modal-button(aria-hidden='true', :close='close')
  v-card-text
    v-alert.mb-4(density="compact" variant="tonal" type="info")
      span(v-t="'thread_arrangement_form.for_everyone'")
    p.text-medium-emphasis(v-t="'thread_arrangement_form.sorting'")
    v-radio-group(v-model="clone.newestFirst")
      v-radio(:value="false")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.earliest'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.earliest_description'")

      v-radio(:value="true")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.latest'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.latest_description'")

    p.text-medium-emphasis(v-t="'thread_arrangement_form.replies'")
    v-radio-group(v-model="clone.maxDepth")
      v-radio(:value="1")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.linear'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.linear_description'")
      v-radio(:value="2")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.nested_once'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.nested_once_description'")
      v-radio(:value="3")
        template(v-slot:label)
          strong(v-t="'thread_arrangement_form.nested_twice'")
          space
          | -
          space
          span(v-t="'thread_arrangement_form.nested_twice_description'")
    v-alert(type="warning" variant="tonal" v-if="clone.maxDepth != discussion.maxDepth")
      span(v-t="'thread_arrangement_form.changing_nesting_is_slow'")
  v-card-actions
    v-spacer
    v-btn(color="primary" variant="elevated" @click="submit()" :loading="clone.processing")
      span(v-t="'common.action.save'")
</template>
