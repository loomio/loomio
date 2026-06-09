<script setup lang="js">
import LmoUrlService from '@/shared/services/lmo_url_service';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import { computed } from 'vue';

const { topicable } = defineProps({
  topicable: Object
});

const topic = computed(() => topicable.topic());
const topicTopicable = computed(() => topic.value.topicable());
const group = computed(() => topicable.group());
const groups = computed(() => {
  if (!group.value) { return []; }
  return group.value.parentsAndSelf().map(group => {
    return {
      title: group.name,
      disabled: false,
      to: group.id ? LmoUrlService.route({model: group}) : '/dashboard/direct_discussions'
    };
  });
});
const breadcrumbs = computed(() => {
  const items = groups.value.slice();
  if (topicable !== topicTopicable.value) {
    items.push({
      title: topicTopicable.value.title,
      disabled: false,
      to: LmoUrlService.route({model: topicTopicable.value})
    });
  }
  return items;
});
const tags = computed(() => topic.value.tags);
const isPinned = computed(() => !!topic.value.pinnedAt);
const canEditTags = computed(() => AbilityService.canEditTags(topic.value));

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

function openTagsModal() {
  EventBus.$emit('openModal', {
    component: 'TopicTagsModal',
    props: {topic: topic.value}
  });
}
</script>

<template lang="pug">
.strand-header
  .d-flex.flex-wrap.align-center.text-body-medium
    v-breadcrumbs.ml-n3.context-panel__breadcrumbs.flex-grow-1(color="anchor" :items="breadcrumbs")
      template(v-slot:divider)
        common-icon(name="mdi-chevron-right")
    tags-display(:tags="tags" :group="group")
    v-btn.strand-header__edit-tags(
      v-if="canEditTags"
      icon
      size="small"
      variant="text"
      :title="$t('loomio_tags.card_title')"
      @click="openTagsModal"
    )
      common-icon.text-medium-emphasis(name="mdi-tag-plus-outline")
  h1.text-headline-large.context-panel__heading#sequence-0.pt-2.mb-4(tabindex="-1" v-intersect="{handler: titleVisible}")
    plain-text(:model='topicable' field='title')
    i.mdi.mdi-pin-outline.context-panel__heading-pin(v-if="isPinned")
</template>

<style lang="sass">
.strand-header
  .v-breadcrumbs
    padding: 4px 10px 4px 10px
</style>
