<script setup>
import { computed, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import Records from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import EventBus from '@/shared/services/event_bus';
import PageLoader from '@/shared/services/page_loader';
import Session from '@/shared/services/session';
import { identity, pickBy } from 'lodash-es';
import TagsFilterMenu from '@/components/tags/filter_menu';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { group } = defineProps({
  group: {type: Object, required: true}
});
const route = useRoute();
const router = useRouter();
const { t } = useI18n();
const { watchRecords } = useWatchRecords();
const topics = ref([]);
const loader = ref(null);
const isMember = ref(false);
const dummyQuery = ref(null);
const per = 25;
const page = computed({
  get: () => parseInt(route.query.page) || 1,
  set: value => router.replace({query: {...route.query, page: value}})
});
const totalPages = computed(() => Math.max(1, Math.ceil((loader.value?.total || 0) / per)));
const loading = computed(() => loader.value?.loading || false);
const noThreads = computed(() => !loading.value && topics.value.length === 0);
const noThreadsMatchingFilters = computed(() => noThreads.value && group.discussionsCount > 0);
const canViewPrivateContent = computed(() => AbilityService.canViewPrivateContent(group));
const canStartThread = computed(() => AbilityService.canStartThread(group));
const unreadCount = computed(() => topics.value.filter(topic => topic.isUnread()).length);
const suggestLockedThreads = computed(() =>
  !['locked', 'unread', 'all'].includes(String(route.query.t)) &&
  group.discussionsCount > (loader.value?.total || 0)
);

function mergeQuery(values) {
  return {query: pickBy({...route.query, ...values}, identity)};
}

function routeQuery(values) {
  router.replace(mergeQuery(values));
}

function selectTag(tag) {
  routeQuery({tag, page: null});
}

function query() {
  const groupIds = group.organisationIds();
  let pinnedTopics = [];
  if (page.value === 1 && !route.query.tag && !['locked', 'unread'].includes(route.query.t)) {
    pinnedTopics = Records.topics.collection.chain().find({
      groupId: {$in: groupIds},
      topicableType: 'Discussion',
      pinnedAt: {$ne: null}
    }).simplesort('pinnedAt', true).data();
  }

  let chain = Records.topics.collection.chain().find({
    groupId: {$in: groupIds},
    topicableType: 'Discussion',
    id: {$nin: pinnedTopics.map(topic => topic.id)}
  }).simplesort('lastActivityAt', true);

  switch (route.query.t) {
    case 'unread': chain = chain.where(topic => topic.isUnread()); break;
    case 'locked': chain = chain.find({lockedAt: {$ne: null}}); break;
    case 'all': break;
    default: chain = chain.find({lockedAt: null});
  }

  if (route.query.tag) chain = chain.where(topic => topic.tags.includes(route.query.tag));

  let pageTopics = [];
  if (loader.value.pageIds[page.value]) {
    pageTopics = chain.find({id: {$in: loader.value.pageIds[page.value]}}).data();
  }
  topics.value = pinnedTopics.concat(pageTopics);

  EventBus.$emit('currentComponent', {
    page: 'groupPage',
    title: group.name,
    group,
    search: {placeholder: t('navbar.search_discussions_in_group', {name: group.parentOrSelf().name})}
  });
}

function fetch() {
  return loader.value.fetch(page.value).then(query);
}

function refresh() {
  isMember.value = !!Session.user().membershipFor(group);
  loader.value = new PageLoader({
    path: 'topics',
    order: 'lastActivityAt',
    params: {
      group_id: group.id,
      exclude_types: 'reaction',
      topicable_type: 'Discussion',
      subgroups: 'mine',
      filter: route.query.t === 'all' ? undefined : (route.query.t || 'unlocked'),
      tags: route.query.tag,
      per
    }
  });
  fetch();
  query();
}

function filterName(filter) {
  switch (filter) {
    case 'unread': return 'discussions_panel.unread';
    case 'locked': return 'discussions_panel.locked';
    case 'all': return 'discussions_panel.all';
    default: return 'discussions_panel.unlocked';
  }
}

function openSearchModal() {
  EventBus.$emit('openModal', {
    component: 'SearchModal',
    persistent: false,
    maxWidth: 900,
    props: {
      initialOrgId: group.isParent() ? group.id : group.parentId,
      initialGroupId: group.isParent() ? null : group.id,
      initialQuery: dummyQuery.value
    }
  });
}

refresh();
watchRecords({
  key: route.params.key,
  collections: ['topics', 'groups', 'memberships'],
  query
});
watch(() => route.query, refresh);
</script>

<template lang="pug">
div.discussions-panel(v-if="group")
  .d-flex.align-center.flex-wrap.pt-4.pb-2
    v-menu
      template(v-slot:activator="{ props }")
        v-btn.discussions-panel__filters.mr-2.text-medium-emphasis(v-bind="props" variant="tonal")
          span(v-t="{path: filterName($route.query.t), args: {count: unreadCount}}")
          common-icon(name="mdi-menu-down")
      v-list
        v-list-item.discussions-panel__filters-unlocked(@click="routeQuery({t: null})")
          v-list-item-title(v-t="'discussions_panel.unlocked'")
        v-list-item.discussions-panel__filters-all(@click="routeQuery({t: 'all'})")
          v-list-item-title(v-t="'discussions_panel.all'")
        v-list-item.discussions-panel__filters-locked(@click="routeQuery({t: 'locked'})")
          v-list-item-title(v-t="'discussions_panel.locked'")
        v-list-item.discussions-panel__filters-unread(@click="routeQuery({t: 'unread'})")
          v-list-item-title(v-t="{path: 'discussions_panel.unread', args: { count: unreadCount }}")

    tags-filter-menu(:group="group" :selected-tag="$route.query.tag" @select="selectTag")
    v-btn.text-medium-emphasis(
      variant="tonal"
      @click="openSearchModal"
    )
      common-icon.mr-1(name="mdiMagnify")
      span(v-t="'common.action.search'")
    v-spacer
    v-btn.discussions-panel__new-topic-button(
      variant="elevated"
      v-if='canStartThread'
      :to="'/discussion_templates/?group_id='+group.id"
      color='primary'
    )

      span(v-t="'discussions_panel.new_discussion'")

  v-alert(color="info" variant="tonal" v-if="noThreadsMatchingFilters")
    v-card-text
      p(v-t="'discussions_panel.no_threads_found_that_match_your_filters'")

  v-alert(color="info" variant="tonal" v-else-if="isMember && noThreads")
    v-card-title(v-t="'discussions_panel.welcome_to_your_new_group'")
    v-card-text
      p(v-t="'discussions_panel.lets_start_a_discussion'")

  v-card.discussions-panel(v-else variant="flat")
    div(v-if="loader.status == 403")
      p.pa-4.text-center(v-t="'error_page.forbidden'")
    div(v-else)
      .discussions-panel__content
        .discussions-panel__list--empty.pa-4(v-if='noThreads')
          p.text-center(v-if='canViewPrivateContent' v-t="'group_page.no_discussions_here'")
          p.text-center(v-if='!canViewPrivateContent' v-t="'group_page.private_discussions'")
        .discussions-panel__list.topic-preview-collection__container(v-if="topics.length")
          v-list.topic-previews(lines="two")
            topic-preview(
              v-for="topic in topics"
              :show-group-name="topic.groupId != group.id"
              :key="topic.id"
              :topic="topic"
              group-page
            )

        loading(v-if="loading && topics.length == 0")

        v-pagination(v-model="page" :length="totalPages" :disabled="totalPages == 1")
        .d-flex.justify-center
          router-link.text-medium-emphasis.text-decoration-none.underline-on-hover.discussions-panel__view-locked-topics.text-center.pa-1(:to="'?t=locked'" v-if="suggestLockedThreads" v-t="'group_page.view_locked_discussions'")

</template>

<style>
.overflow-x-auto {
  overflow-x: auto;
}
</style>
