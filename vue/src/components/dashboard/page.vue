<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import Records        from '@/shared/services/records';
import Session        from '@/shared/services/session';
import EventBus       from '@/shared/services/event_bus';
import RecordLoader   from '@/shared/services/record_loader';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { watchRecords } = useWatchRecords();

const dashboardLoaded = ref(Records.topics.collection.data.length > 0);
const topics = ref([]);
const loader = ref(null);

const noGroups = computed(() => Session.user().groups().length === 0);

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

function query() {
  const groupIds = Session.user().groupIds();
  let chain = Records.topics.collection.chain();
  chain = chain.find({lockedAt: null});
  chain = chain.find({discardedAt: null});
  chain = chain.find({$or: [
    {groupId: {$in: groupIds}},
    {readerGuest: true}
  ]});
  chain = chain.simplesort('lastActivityAt', true);
  chain = chain.limit(30);
  topics.value = chain.data();
}

function fetch() {
  if (!loader.value) { return; }
  loader.value.fetchRecords().then(() => { dashboardLoaded.value = true; });
}

function refresh() {
  if (!Session.isSignedIn()) { return; }
  fetch();
  query();
}

function init() {
  loader.value = new RecordLoader({
    collection: 'topics',
    params: {
      per: 30,
      exclude_types: 'reaction'
    }
  });

  watchRecords({
    key: 'dashboard',
    collections: ['topics', 'memberships'],
    query
  });

  refresh();
}

init();
EventBus.$on('signedIn', init);

onMounted(() => {
  EventBus.$emit('content-title-visible', false);
  EventBus.$emit('currentComponent', {
    titleKey: 'dashboard_page.dashboard',
    page: 'dashboardPage',
    group: null,
  });
});

onUnmounted(() => {
  EventBus.$off('signedIn', init);
});
</script>

<template lang="pug">
v-main
  v-container.dashboard-page.max-width-1024.px-0.px-sm-3
    h1.text-h4.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'dashboard_page.dashboard'")

    dashboard-polls-panel

    v-card.mb-3(v-if='!dashboardLoaded')
      v-list(lines="two")
        v-list-subheader(v-t="'dashboard_page.recent_threads'")
        loading-content(
          :lineCount='2'
          v-for='(item, index) in [1,2,3]'
          :key='index' )

    div(v-if="dashboardLoaded")
      section.dashboard-page__loaded
        .dashboard-page__empty(v-if='topics.length == 0')
          p(v-html="$t('dashboard_page.no_groups.show_all')" v-if='noGroups')
          .dashboard-page__no-threads(v-if='!noGroups')
            span(v-t="'dashboard_page.no_threads.show_all'")
        .dashboard-page__collections(v-if='topics.length')
          v-card.mb-3.thread-preview-collection__container.thread-previews-container
            v-list.thread-previews(lines="two")
              v-list-subheader(v-t="'dashboard_page.recent_threads'")
              thread-preview(
                v-for="topic in topics"
                :key="topic.id"
                :topic="topic")
          .dashboard-page__footer(v-if='!loader.exhausted')
          loading(v-show='loader.loading')
</template>
