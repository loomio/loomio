<script setup lang="js">
import { ref, onUnmounted } from 'vue';
import { sum, values, sortBy } from 'lodash-es';

import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import EventBus      from '@/shared/services/event_bus';
import ThreadFilter  from '@/shared/services/thread_filter';
import ThreadPreviewCollection from '@/components/thread/preview_collection';
import { useWatchRecords } from '@/composables/useWatchRecords';

const threadLimit = 50;
const filters = [
  'only_threads_in_my_groups',
  'show_unread',
  'show_recent',
  'hide_muted',
  'hide_dismissed'
];

const groups = ref([]);
const viewsByGroup = ref({});
const unreadCount = ref(0);
const loading = ref(false);

const { watchRecords } = useWatchRecords();

function fetchInbox() {
  if (!Session.isSignedIn()) return;
  loading.value = true;
  Records.users.findOrFetchGroups();
  Records.topics.fetch({
    params: { unread: 1, per: 50 }
  }).finally(() => { loading.value = false; });
}

function query() {
  groups.value = sortBy(Session.user().inboxGroups(), 'name');
  viewsByGroup.value = {};
  groups.value.forEach(group => {
    viewsByGroup.value[group.key] = ThreadFilter({ filters, group });
  });
  unreadCount.value = sum(values(viewsByGroup.value), v => v.length);
}

function startGroup() {
  EventBus.$emit('openModal', {
    component: 'GroupNewForm',
    props: { group: Records.groups.build() }
  });
}

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

watchRecords({
  key: 'inbox',
  collections: ['topics', 'groups', 'memberships'],
  query
});

EventBus.$emit('currentComponent', {
  titleKey: 'inbox_page.unread_discussions',
  page: 'inboxPage'
});

EventBus.$on('signedIn', fetchInbox);
onUnmounted(() => EventBus.$off('signedIn', fetchInbox));

fetchInbox();
</script>

<template lang="pug">
v-main
  v-container.inbox-page.thread-preview-collection__container.max-width-1024.px-0.px-sm-3(grid-list-lg)
    h1.text-h4.my-4(tabindex="-1" v-intersect="{handler: titleVisible}" v-t="'inbox_page.unread_discussions'")
    section.dashboard-page__loading(v-if='unreadCount == 0 && loading' aria-hidden='true')
      .thread-previews-container
        loading-content.thread-preview(:lineCount='2' v-for='(item, index) in [1,2,3,4,5,6,7,8,9,10]' :key='index')
    section.inbox-page__threads(v-if='unreadCount > 0 || !loading')
      v-card.mb-3(v-show='unreadCount == 0')
        v-card-text
          span(v-t="'inbox_page.no_discussions'")
          span 🙌
      v-card.mb-3(v-show='groups.length == 0')
        v-card-text
        p(v-t="'inbox_page.no_groups.explanation'")
        button.lmo-btn-link--blue(v-t="'inbox_page.no_groups.start'", @click='startGroup()')
        | &nbsp;
        span(v-t="'inbox_page.no_groups.or'")
        | &nbsp;
        span(v-html="$t('inbox_page.no_groups.join_group')")
      .inbox-page__group(v-for='group in groups', :key='group.id')
        v-card.mb-3(v-if='viewsByGroup[group.key].length > 0')
          v-list
            v-list-subheader
              router-link.inbox-page__group-link(:to="'/g/' + group.key") {{group.name}}
            thread-preview-collection(:threads="viewsByGroup[group.key]", :limit="threadLimit")
        //- strand-wall(:threads="viewsByGroup[group.key]")
</template>

<style lang="sass">
.inbox-page__group-link
  color: inherit
  text-decoration: none
</style>
