<script setup lang="js">
import { ref, onUnmounted, watch } from 'vue';
import { useRoute } from 'vue-router';

import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import RecordLoader from '@/shared/services/record_loader';
import { useWatchRecords } from '@/composables/useWatchRecords';

const route = useRoute();
const topics = ref([]);
const loader = ref({});

const { watchRecords } = useWatchRecords();

function init() {
  loader.value = new RecordLoader({
    collection: 'topics',
    params: { direct: 1 }
  });
  loader.value.fetchRecords();

  watchRecords({
    key: 'direct-topics',
    collections: ['topics'],
    query: () => {
      topics.value = Records.topics.collection.chain()
        .find({groupId: null, discardedAt: null})
        .simplesort('lastActivityAt', true)
        .data();
    }
  });
}

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

EventBus.$emit('content-title-visible', false);
EventBus.$on('signedIn', init);
onUnmounted(() => EventBus.$off('signedIn', init));

watch(() => route.query, init);

init();
</script>

<template lang="pug">
v-main
  v-container.topics-page.max-width-1024.px-0.px-sm-3
    h1.text-headline-large.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'sidebar.direct_discussions'")
    v-layout.pb-3
      v-spacer
      v-btn.topics-page__new-topic-button(color="primary" to="/discussion_templates/" v-t="'discussions_panel.new_discussion'")

    v-card.mb-3.dashboard-page__loading(v-if='loader.loading && topics.length == 0' aria-hidden='true')
      v-list(lines="two")
        loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index' )
    div(v-else)
      section.topics-page__loaded
        v-alert.mb-3(v-if='topics.length == 0' type="info" variant="tonal")
          div(v-t="'threads_page.no_direct_discussions_title'")
          div.text-body-medium.mt-2(v-t="'threads_page.no_direct_discussions_helptext'")
        .topics-page__collections(v-else)
          v-card.mb-3.topic-preview-collection__container
            v-list.topic-previews(lines="two")
              topic-preview(v-for="topic in topics", :key="topic.id", :topic="topic")

      .d-flex.align-center.justify-center(v-if='topics.length > 0')
        div
          p.text-center.text-medium-emphasis(v-t="{path: 'members_panel.loaded_of_total', args: {loaded: topics.length, total: loader.total}}")
          v-btn(variant="tonal" color="primary" v-if="!loader.exhausted" @click="loader.fetchRecords()", :loading="loader.loading", v-t="'common.action.load_more'")
</template>
