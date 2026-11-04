<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService from '@/shared/services/lmo_url_service';
import TagsDisplay from './display.vue';
import TopicTagsMenu from './topic_tags_menu.vue';

const { topicItem } = defineProps({topicItem: {type: Object, required: true}});
const { t } = useI18n();
const topic = computed(() => topicItem.topic());
const canEdit = computed(() => AbilityService.canTagTopicItem(topicItem));
const tagRoute = tag => ({path: LmoUrlService.route({model: topic.value.topicable()}), query: {tag}});
</script>

<template lang="pug">
.item-tags.d-flex.flex-wrap.align-center.justify-end(v-if="topicItem.tags.length")
  tags-display.d-flex.flex-wrap.justify-end.text-medium-emphasis(:tags="topicItem.tags" :group="topic.group()" :tag-route="tagRoute" density="compact")
  topic-tags-menu(v-if="canEdit" :topic="topic" :topic-item="topicItem" button-size="x-small" button-density="comfortable" :aria-label="t('loomio_tags.apply_tags')")
</template>

<style>
.item-tags {
  max-width: 100%;
}
</style>
