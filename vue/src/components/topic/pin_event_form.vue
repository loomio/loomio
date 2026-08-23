<script lang="js">
import Flash from '@/shared/services/flash';
import EventBus from '@/shared/services/event_bus';

export default {
  props: {
    topic_item: Object
  },

  data() {
    return {
      title: null,
      loading: false
    };
  },

  mounted() {
    this.title = (window.getSelection() && window.getSelection().toString()) || this.topic_item.pinnedTitle || this.topic_item.suggestedTitle();
    this.$nextTick(() => this.$refs.focus.focus());
  },

  methods: {
    submit() {
      this.loading = true;
      this.topic_item.pin(this.title).then(() => {
        Flash.success('activity_card.event_pinned');
        EventBus.$emit('closeModal');
      });
    }
  }
};

</script>
<template lang="pug">
v-card.pin-topic_item-form(:title="$t('pin_event_form.title')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    v-form#pin-topic_item-form(@submit.prevent="submit()")
      v-text-field(:disabled="loading" ref="focus" v-model="title" :label="$t('pin_event_form.title_label')")
  v-card-actions
    v-spacer
    v-btn(color="primary" type="submit" form="pin-topic_item-form" :loading="loading")
      span(v-t="'common.action.save'")
</template>
