<script setup lang="js">
import { computed, onBeforeUnmount, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { identity, intersection, pickBy, uniq } from 'lodash-es';
import Records from '@/shared/services/records';
import GroupAbility from '@/shared/abilities/group_ability';
import DiscussionAbility from '@/shared/abilities/discussion_ability';
import EventBus from '@/shared/services/event_bus';
import PageLoader from '@/shared/services/page_loader';
import Session from '@/shared/services/session';
import { unreadCutoffDate } from '@/shared/helpers/unread_cutoff.mjs';
import TagsFilterMenu from '@/components/tags/filter_menu';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';
import ListPagination from '@/components/common/list_pagination.vue';

const { dashboard } = defineProps({
  dashboard: { type: Boolean, default: false }
});

const { t } = useI18n();
const route = useRoute();
const router = useRouter();

const group = ref(null);
const loader = ref(null);
const isMember = ref(false);
const dummyQuery = ref(null);

const pageSize = computed(() => {
  const n = parseInt(route.query.limit, 10);
  return [25, 50, 100].includes(n) ? n : 25;
});

const lockFilter = computed(() => (
  ['all', 'locked'].includes(route.query.t) ? route.query.t : null
));

const sortOrder = computed(() => (
  ['newest', 'oldest'].includes(route.query.sort) ? route.query.sort : 'recent_activity'
));

const sortOptions = computed(() => [
  { value: 'recent_activity', label: t('pagination.sort.recent_activity') },
  { value: 'newest', label: t('pagination.sort.newest') },
  { value: 'oldest', label: t('pagination.sort.oldest') }
]);

const isUnreadFilter = computed(() => (
  Boolean(route.query.unread) || route.query.t === 'unread'
));

const isDirectFilter = computed(() => (
  dashboard && (Boolean(route.query.direct) || route.query.t === 'direct')
));

const subgroupsFilter = computed(() => {
  if (!group.value || !(group.value.subgroupsCount > 0)) { return null; }
  return ['mine', 'all'].includes(route.query.subgroups) ? route.query.subgroups : null;
});

const includeSubgroups = computed(() => Boolean(subgroupsFilter.value));

const groupFilter = computed(() => {
  if (!group.value) { return null; }
  if (subgroupsFilter.value === 'all') { return { $in: group.value.organisationIds() }; }
  if (subgroupsFilter.value === 'mine') {
    return { $in: uniq([group.value.id].concat(intersection(group.value.organisationIds(), Session.user().groupIds()))) };
  }
  return group.value.id;
});

const noGroups = computed(() => dashboard && Session.user().groups().length === 0);

const page = computed({
  get: () => parseInt(route.query.page) || 1,
  set: (val) => router.replace({ query: Object.assign({}, route.query, { page: val }) })
});

const totalPages = computed(() => Math.max(1, Math.ceil((loader.value?.total || 0) / pageSize.value)));
const isLoading = computed(() => Boolean(loader.value?.loading));

const topics = computed(() => {
  if (!dashboard && !group.value) { return []; }

  const isDefaultSort = sortOrder.value === 'recent_activity';
  const sortField = isDefaultSort ? 'lastActivityAt' : 'createdAt';
  const sortDesc = sortOrder.value !== 'oldest';

  let pinnedTopics = [];
  if (!dashboard && isDefaultSort && page.value == 1 && !route.query.tag && !isUnreadFilter.value && lockFilter.value !== 'locked') {
    pinnedTopics = Records.topics.collection.chain().find({
      groupId: groupFilter.value,
      discardedAt: null,
      pinnedAt: { $ne: null }
    }).simplesort('pinnedAt', true).data();
  }
  const pinnedIdSet = new Set(pinnedTopics.map(topic => topic.id));

  const pageIds = loader.value?.pageIds?.[page.value];
  if (Array.isArray(pageIds)) {
    const items = pageIds
      .filter(id => !pinnedIdSet.has(id))
      .map(id => Records.topics.findById(id))
      .filter(topic => topic && !topic.discardedAt);
    return pinnedTopics.concat(items);
  }

  if (page.value !== 1 || !isLoading.value) {
    return pinnedTopics;
  }

  let chain;
  if (dashboard) {
    if (isDirectFilter.value) {
      chain = Records.topics.collection.chain().find({
        groupId: null,
        discardedAt: null
      });
    } else {
      const groupIds = Session.user().groupIds();
      chain = Records.topics.collection.chain().find({
        discardedAt: null,
        $or: [
          { groupId: { $in: groupIds } },
          { readerGuest: true }
        ]
      });
    }
  } else {
    chain = Records.topics.collection.chain().find({
      groupId: groupFilter.value,
      discardedAt: null,
      id: { $nin: Array.from(pinnedIdSet) }
    });
  }

  switch (lockFilter.value) {
    case 'locked':
      chain = chain.find({ lockedAt: { $ne: null } });
      break;
    case 'all':
      break;
    default:
      chain = chain.find({ lockedAt: null });
      break;
  }

  if (isUnreadFilter.value) {
    chain = chain.find({ lastActivityAt: { $gt: unreadCutoffDate() } }).where(topic => topic.isUnread());
  }

  if (route.query.tag) {
    const tagName = route.query.tag;
    chain = chain.where(topic => topic.tags.includes(tagName));
  }

  return pinnedTopics.concat(chain.simplesort(sortField, sortDesc).limit(pageSize.value).data());
});

const noThreads = computed(() => !isLoading.value && topics.value.length === 0);

const hasActiveFilters = computed(() => (
  Boolean(isUnreadFilter.value || isDirectFilter.value || lockFilter.value || route.query.tag)
));

const emptyFilterMessage = computed(() => {
  const qualifiers = [];
  if (isUnreadFilter.value) { qualifiers.push(t('group_cards.filter_qualifier_unread')); }
  if (isDirectFilter.value) { qualifiers.push(t('group_cards.filter_qualifier_direct')); }
  if (lockFilter.value === 'locked') {
    qualifiers.push(t('group_cards.filter_qualifier_locked'));
  } else if (lockFilter.value !== 'all') {
    qualifiers.push(t('group_cards.filter_qualifier_unlocked'));
  }
  const filters = qualifiers.join(', ');
  if (route.query.tag) {
    return filters
      ? t('group_cards.no_filtered_threads_with_tag', { filters, tag: route.query.tag })
      : t('group_cards.no_threads_with_tag', { tag: route.query.tag });
  }
  return filters
    ? t('group_cards.no_filtered_threads', { filters })
    : t('discussions_panel.no_threads_found_that_match_your_filters');
});

const noThreadsMatchingFilters = computed(() => (
  !dashboard && noThreads.value && (hasActiveFilters.value || ((group.value.discussionsCount || 0) + (group.value.pollsCount || 0)) > 0)
));

const canViewPrivateContent = computed(() => dashboard || GroupAbility.canSeePrivateContent(group.value));

const canStartThread = computed(() => {
  if (group.value) { return DiscussionAbility.canCreate(group.value); }
  return dashboard && isDirectFilter.value && Session.isSignedIn();
});

const newThreadRoute = computed(() => (
  group.value ? `/discussion_templates/?group_id=${group.value.id}` : '/discussion_templates/'
));

const isLoggedIn = computed(() => Session.isSignedIn());

function mergeQuery(obj) {
  return { query: pickBy(Object.assign({}, route.query, obj), identity) };
}

function routeQuery(obj) {
  router.replace(mergeQuery(obj));
}

function selectTag(tag) {
  routeQuery({ tag, page: null });
}

function selectSubgroups(val) {
  routeQuery({ subgroups: val, page: null });
}

function selectSort(val) {
  routeQuery({ sort: val === 'recent_activity' ? null : val, page: null });
}

function selectPageSize(val) {
  routeQuery({ limit: val === 25 ? null : val, page: null });
}

function toggleUnread() {
  routeQuery({
    unread: isUnreadFilter.value ? null : '1',
    t: route.query.t === 'unread' ? null : route.query.t,
    page: null
  });
}

function toggleDirect() {
  routeQuery({
    direct: isDirectFilter.value ? null : '1',
    t: route.query.t === 'direct' ? null : route.query.t,
    page: null
  });
}

function filterName(filter) {
  switch (filter) {
    case 'locked': return 'discussions_panel.locked';
    case 'all': return 'discussions_panel.all';
    default: return 'discussions_panel.unlocked';
  }
}

function fetch() {
  loader.value.fetch(page.value);
}

function refresh() {
  const sortParam = sortOrder.value === 'recent_activity' ? undefined : sortOrder.value;
  const orderField = sortOrder.value === 'recent_activity' ? 'lastActivityAt' : 'createdAt';

  if (dashboard) {
    group.value = null;
    isMember.value = false;
    loader.value = new PageLoader({
      path: 'topics',
      order: orderField,
      params: {
        filter: lockFilter.value === 'all' ? undefined : (lockFilter.value || 'unlocked'),
        unread: isUnreadFilter.value ? 1 : undefined,
        last_activity_gte: isUnreadFilter.value ? unreadCutoffDate().toISOString() : undefined,
        direct: isDirectFilter.value ? 1 : undefined,
        tags: route.query.tag,
        sort: sortParam,
        limit: pageSize.value
      }
    });
    fetch();
    return;
  }

  // GroupPage loads the group before mounting this panel.
  const currentGroup = Records.groups.fuzzyFind(route.params.key);
  group.value = currentGroup;
  isMember.value = Boolean(Session.user().membershipFor(currentGroup));

  loader.value = new PageLoader({
    path: 'topics',
    order: orderField,
    params: {
      group_id: currentGroup.id,
      subgroups: subgroupsFilter.value || undefined,
      filter: lockFilter.value === 'all' ? undefined : (lockFilter.value || 'unlocked'),
      unread: isUnreadFilter.value ? 1 : undefined,
      last_activity_gte: isUnreadFilter.value ? unreadCutoffDate().toISOString() : undefined,
      tags: route.query.tag,
      sort: sortParam,
      limit: pageSize.value
    }
  });

  fetch();

  EventBus.$emit('currentComponent', {
    page: 'groupPage',
    title: currentGroup.name,
    group: currentGroup,
    search: {
      placeholder: t('navbar.search_discussions_in_group', { name: currentGroup.parentOrSelf().name })
    }
  });
}

function hardRefresh() {
  if (dashboard) {
    refresh();
  } else {
    Records.groups.remote.fetchById(route.params.key).then(refresh);
  }
}

function openSearchModal() {
  let initialOrgId = null;
  let initialGroupId = null;

  if (group.value) {
    if (group.value.isParent()) {
      initialOrgId = group.value.id;
    } else {
      initialOrgId = group.value.parentId;
      initialGroupId = group.value.id;
    }
  }

  EventBus.$emit('openModal', {
    component: 'SearchModal',
    persistent: false,
    maxWidth: 900,
    props: {
      initialOrgId,
      initialGroupId,
      initialQuery: dummyQuery.value
    }
  });
}

refresh();
EventBus.$on('signedIn', hardRefresh);
EventBus.$on('joinedGroup', hardRefresh);

onBeforeUnmount(() => {
  EventBus.$off('signedIn', hardRefresh);
  EventBus.$off('joinedGroup', hardRefresh);
});

watch(() => route.query, refresh);
watch(() => route.params.key, refresh);
</script>

<template lang="pug">
div.discussions-panel(v-if="dashboard || group")
  .d-flex.align-center.flex-wrap.ga-2.pt-4.pb-2
    subgroups-filter-menu(v-if="group" :group="group" :selected="subgroupsFilter" @select="selectSubgroups")
    v-menu
      template(v-slot:activator="{ props }")
        v-btn.discussions-panel__filters.text-medium-emphasis(v-bind="props" variant="tonal")
          span {{ t(filterName(lockFilter)) }}
          common-icon(name="mdi-menu-down")
      v-list(density="compact")
        v-list-item.discussions-panel__filters-all(:active="lockFilter === 'all'" @click="routeQuery({t: 'all'})")
          v-list-item-title {{ t('discussions_panel.all') }}
        v-list-item.discussions-panel__filters-locked(:active="lockFilter === 'locked'" @click="routeQuery({t: 'locked'})")
          v-list-item-title {{ t('discussions_panel.locked') }}
        v-list-item.discussions-panel__filters-unlocked(:active="!lockFilter" @click="routeQuery({t: null})")
          v-list-item-title {{ t('discussions_panel.unlocked') }}

    v-btn.discussions-panel__unread-toggle(
      v-if="isLoggedIn"
      variant="tonal"
      :color="isUnreadFilter ? 'primary' : undefined"
      :class="{ 'text-medium-emphasis': !isUnreadFilter }"
      :aria-pressed="isUnreadFilter"
      @click="toggleUnread"
    )
      common-icon.mr-1(v-if="isUnreadFilter" name="mdi-check" size="small" color="currentColor")
      span {{ t('common.unread') }}

    v-btn.discussions-panel__direct-toggle(
      v-if="dashboard"
      variant="tonal"
      :color="isDirectFilter ? 'primary' : undefined"
      :class="{ 'text-medium-emphasis': !isDirectFilter }"
      :aria-pressed="isDirectFilter"
      @click="toggleDirect"
    )
      common-icon.mr-1(v-if="isDirectFilter" name="mdi-check" size="small" color="currentColor")
      span {{ t('dashboard_cards.direct') }}

    tags-filter-menu(:group="group" :selected-tag="route.query.tag" @select="selectTag")
    v-tooltip(location="bottom" :text="t('common.action.search')")
      template(#activator="{ props }")
        v-btn.text-medium-emphasis(
          v-bind="props"
          icon
          density="comfortable"
          variant="tonal"
          :aria-label="t('common.action.search')"
          @click="openSearchModal"
        )
          common-icon(name="mdi-magnify")
    v-spacer
    v-btn.discussions-panel__new-topic-button(
      v-if="canStartThread"
      :to="newThreadRoute"
      variant="elevated"
      color="primary"
    )
      span {{ t('discussions_panel.new_thread') }}

  v-alert(color="info" variant="tonal" v-if="noThreadsMatchingFilters")
    v-card-text
      p {{ emptyFilterMessage }}

  v-alert(color="info" variant="tonal" v-else-if="isMember && noThreads")
    v-card-title {{ t('discussions_panel.welcome_to_your_new_group') }}
    v-card-text
      p {{ t('discussions_panel.lets_start_a_discussion') }}

  v-card.discussions-panel(v-else variant="flat")
    div(v-if="loader.status == 403")
      p.pa-4.text-center {{ t('error_page.forbidden') }}
    div(v-else)
      .discussions-panel__content
        .discussions-panel__list--empty.pa-4(v-if="noThreads")
          template(v-if="dashboard")
            p.text-center(v-if="noGroups" v-html="t('dashboard_page.no_groups.show_all')")
            p.text-center(v-else-if="hasActiveFilters") {{ emptyFilterMessage }}
            p.text-center(v-else) {{ t('dashboard_page.no_threads.show_all') }}
          template(v-else)
            p.text-center(v-if="canViewPrivateContent") {{ t('group_page.no_discussions_here') }}
            p.text-center(v-if="!canViewPrivateContent") {{ t('group_page.private_discussions') }}
        .discussions-panel__list.topic-preview-collection__container(v-if="topics.length")
          v-list.topic-previews(lines="two")
            topic-preview(
              v-for="topic in topics"
              :show-group-name="dashboard || includeSubgroups"
              :key="topic.id"
              :topic="topic"
              :group-page="Boolean(group)"
            )

        loading(v-if="isLoading && topics.length == 0")

  list-pagination(
    v-if="!noThreads && loader && loader.status != 403"
    :page="page"
    :total-pages="totalPages"
    :page-size="pageSize"
    :sort="sortOrder"
    :sort-options="sortOptions"
    :disabled="isLoading"
    @update:page="page = $event"
    @update:page-size="selectPageSize"
    @update:sort="selectSort"
  )
</template>

<style>
.overflow-x-auto {
  overflow-x: auto;
}
</style>
