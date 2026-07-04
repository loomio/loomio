<script setup lang="js">
import TopicTagsPicker from '@/components/tags/topic_tags_picker';
import { ref, watch } from 'vue';

const { topic, buttonSize, buttonVariant } = defineProps({
  topic: {
    type: Object,
    required: true
  },
  buttonSize: {
    type: String,
    default: 'small'
  },
  buttonVariant: {
    type: String,
    default: 'text'
  }
});

const open = ref(false);
const picker = ref(null);

watch(open, value => {
  if (value) { picker.value?.reset(); }
});
</script>

<template lang="pug">
v-menu.topic-tags-menu(v-model="open" :close-on-content-click="false" location="bottom")
  template(v-slot:activator="{ props }")
    slot(name="activator" :props="props")
      v-btn.topic-tags-menu__button(
        v-bind="props"
        icon
        :size="buttonSize"
        :variant="buttonVariant"
        :title="$t('loomio_tags.select_tags')"
        @click.prevent.stop
      )
        common-icon.text-medium-emphasis(name="mdi-tag-plus-outline")
  v-card.topic-tags-menu__popover(min-width="280" max-width="360")
    topic-tags-picker(
      ref="picker"
      :topic="topic"
      :watch-key="'topicTagsMenu' + topic.id"
      @before-open-external="open = false"
      @close="open = false"
    )
</template>
