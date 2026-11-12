<script setup>
import { computed } from 'vue';
import TopicItemService from '@/shared/services/topic_item_service';

const { topic_item, itemable } = defineProps({topic_item: Object, itemable: Object});
const menuActions = computed(() => ({edit_item_tags: TopicItemService.actions(topic_item).edit_item_tags}));
</script>

<template lang="pug">
section.outcome-created.topic-item__outcome-created(:id="'outcome-' + itemable.id")
  topic-item-headline(:topic_item="topic_item" :itemable="itemable")
  formatted-text.topic-item__body(:model="itemable" field="statement")
  attachment-list(:attachments="itemable.attachments")
  action-dock(:model="itemable" :actions="{}" :menu-actions="menuActions" size="small" left)
</template>
