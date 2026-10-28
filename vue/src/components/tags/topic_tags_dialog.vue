<script setup lang="js">
import TopicTagsPicker from '@/components/tags/topic_tags_picker';

const { topic, topicItem, close } = defineProps({
  topicItem: Object,
  topic: {
    type: Object,
    required: true
  },
  close: Function
});
</script>

<template lang="pug">
v-card.topic-tags-dialog(:title="$t('loomio_tags.apply_tags')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")
  topic-tags-picker(
    :topic="topic"
    :topic-item="topicItem"
    :watch-key="'topicTagsDialog' + topic.id"
  )
</template>
