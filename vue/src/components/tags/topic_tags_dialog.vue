<script setup lang="js">
import TopicTagsPicker from '@/components/tags/topic_tags_picker';

const { topic, close } = defineProps({
  topic: {
    type: Object,
    required: true
  },
  close: Function
});
</script>

<template lang="pug">
v-card.topic-tags-dialog(:title="$t('loomio_tags.select_tags')")
  topic-tags-picker(
    :topic="topic"
    :watch-key="'topicTagsDialog' + topic.id"
    @close="close"
  )
</template>
