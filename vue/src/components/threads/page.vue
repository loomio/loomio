<script setup lang="js">
import { ref, onUnmounted, watch } from 'vue';
import { useRoute } from 'vue-router';

import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import RecordLoader from '@/shared/services/record_loader';
import { useWatchRecords } from '@/composables/useWatchRecords';

const route = useRoute();
const threads = ref([]);
const loader = ref({});

const { watchRecords } = useWatchRecords();

function init() {
  loader.value = new RecordLoader({
    collection: 'topics',
    params: { direct: 1 }
  });
  loader.value.fetchRecords();

  watchRecords({
    key: 'direct-threads',
    collections: ['topics'],
    query: () => {
      threads.value = Records.topics.collection.chain()
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
  v-container.threads-page.max-width-1024.px-0.px-sm-3
    h1.text-h4.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'sidebar.direct_discussions'")
    v-layout.pb-3
      v-spacer
      v-btn.threads-page__new-thread-button(color="primary" to="/discussion_templates/" v-t="'discussions_panel.new_discussion'")

    v-card.mb-3.dashboard-page__loading(v-if='loader.loading && threads.length == 0' aria-hidden='true')
      v-list(lines="two")
        loading-content(:lineCount='2' v-for='(item, index) in [1,2,3]' :key='index' )
    div(v-else)
      section.threads-page__loaded
        v-alert.mb-3(v-if='threads.length == 0' type="info" variant="tonal")
          div(v-t="'threads_page.no_direct_discussions_title'")
          div.text-body-2.mt-2(v-t="'threads_page.no_direct_discussions_helptext'")
        .threads-page__collections(v-else)
          v-card.mb-3.thread-preview-collection__container
            v-list.thread-previews(lines="two")
              thread-preview(v-for="topic in threads", :key="topic.id", :topic="topic")

      .d-flex.align-center.justify-center(v-if='threads.length > 0')
        div
          p.text-center.text-medium-emphasis(v-t="{path: 'members_panel.loaded_of_total', args: {loaded: threads.length, total: loader.total}}")
          v-btn(v-if="!loader.exhausted" @click="loader.fetchRecords()", :loading="loader.loading", v-t="'common.action.load_more'")
</template>
