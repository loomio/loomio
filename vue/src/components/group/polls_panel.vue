<script setup lang="js">
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';
import { intersection, pickBy, identity, uniq } from 'lodash-es';

import AppConfig from '@/shared/services/app_config';
import PollAbility from '@/shared/abilities/poll_ability';
import Records from '@/shared/services/records';
import PageLoader from '@/shared/services/page_loader';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import TagsFilterMenu from '@/components/tags/filter_menu';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';
import ListPagination from '@/components/common/list_pagination.vue';
import { usePendingPolls } from '@/composables/usePendingPolls';

const { dashboard, defaultStatus } = defineProps({
  dashboard: { type: Boolean, default: false },
  defaultStatus: { type: String, default: null }
});

const { t } = useI18n();
const route = useRoute();
const router = useRouter();

const group = computed(() => (dashboard ? null : Records.groups.fuzzyFind(route.params.key)));
const loader = ref(null);
const pollTypes = AppConfig.pollTypes;
const dummyQuery = ref(null);
const { loadPendingPolls, findPendingPolls, loading: pendingPollsLoading } = usePendingPolls();

const pageSize = computed(() => {
  const n = parseInt(route.query.limit, 10);
  return [25, 50, 100].includes(n) ? n : 25;
});

const effectiveStatus = computed(() => (
  route.query.status !== undefined ? (route.query.status || null) : defaultStatus
));
const sortOrder = computed(() => (
  ['closing_soon', 'oldest'].includes(route.query.sort) ? route.query.sort : 'newest'
));
const sortOptions = computed(() => [
  { value: 'newest', label: t('pagination.sort.newest') },
  { value: 'closing_soon', label: t('pagination.sort.closing_soon') },
  { value: 'oldest', label: t('pagination.sort.oldest') }
]);
const subgroupsFilter = computed(() => (
  group.value && group.value.subgroupsCount > 0 && ['mine', 'all'].includes(route.query.subgroups)
    ? route.query.subgroups
    : null
));
const includeSubgroups = computed(() => Boolean(subgroupsFilter.value));

const page = computed({
  get: () => parseInt(route.query.page) || 1,
  set: (val) => router.replace({query: Object.assign({}, route.query, {page: val})})
});

const totalPages = computed(() => Math.max(1, Math.ceil((loader.value.total || 0) / pageSize.value)));
const canStartPoll = computed(() => Boolean(group.value) && PollAbility.canCreateInGroup(group.value));

const mergeQuery = (obj) => {
  const next = Object.assign({}, route.query, obj);
  return {
    query: pickBy(next, (v, k) => (k === 'status' && v === '' && defaultStatus) || identity(v))
  };
};

const startNewPoll = () => {
  router.push('/p/new?group_id=' + group.value.id);
};

const selectTag = (tag) => {
  router.replace(mergeQuery({tag, page: null}));
};

const selectSubgroups = (val) => {
  router.replace(mergeQuery({ subgroups: val, page: null }));
};

const selectSort = (val) => {
  router.replace(mergeQuery({ sort: val === 'newest' ? null : val, page: null }));
};

const selectPageSize = (val) => {
  router.replace(mergeQuery({ limit: val === 25 ? null : val, page: null }));
};

const openSearchModal = () => {
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
      initialType: 'Poll',
      initialOrgId,
      initialGroupId,
      initialQuery: dummyQuery.value
    }
  });
};

const initLoader = () => {
  const sortParam = sortOrder.value === 'newest' ? undefined : sortOrder.value;
  const orderField = sortOrder.value === 'closing_soon' ? 'closingAt' : 'createdAt';
  const params = {
    exclude_types: 'group',
    status: effectiveStatus.value,
    poll_type: route.query.poll_type,
    tags: route.query.tag,
    sort: sortParam,
    limit: pageSize.value
  };
  if (group.value) {
    params.group_key = group.value.key;
    params.subgroups = subgroupsFilter.value || 'none';
  }
  loader.value = new PageLoader({
    path: 'polls',
    order: orderField,
    params
  });
};

const isLivePendingPolls = computed(() => (
  dashboard &&
  effectiveStatus.value === 'vote' &&
  !route.query.poll_type &&
  !route.query.tag &&
  sortOrder.value === 'newest' &&
  page.value === 1
));

const isLoading = computed(() => (
  isLivePendingPolls.value ? pendingPollsLoading.value : Boolean(loader.value?.loading)
));

const polls = computed(() => {
  if (isLivePendingPolls.value) {
    return findPendingPolls();
  }

  const pageIds = loader.value?.pageIds?.[page.value];
  if (Array.isArray(pageIds)) {
    return pageIds
      .map(id => Records.polls.findById(id))
      .filter(poll => poll && !poll.discardedAt);
  }

  if (page.value !== 1 || !loader.value?.loading) {
    return [];
  }

  let chain = Records.polls.collection.chain();
  if (group.value) {
    let groupFilter = group.value.id;
    if (subgroupsFilter.value === 'all') {
      groupFilter = { $in: group.value.organisationIds() };
    } else if (subgroupsFilter.value === 'mine') {
      groupFilter = { $in: uniq([group.value.id].concat(intersection(group.value.organisationIds(), Session.user().groupIds()))) };
    }
    chain = chain.find({groupId: groupFilter});
  }
  chain = chain.find({discardedAt: null});

  switch (effectiveStatus.value) {
    case 'active':
      chain = chain.find({'closedAt': null});
      break;
    case 'closed':
      chain = chain.find({'closedAt': {$ne: null}});
      break;
    case 'vote':
      chain = chain.find({'closedAt': null}).where(p => p.iCanVote() && !p.iHaveVoted());
      break;
  }

  if (route.query.poll_type) {
    chain = chain.find({'pollType': route.query.poll_type});
  }

  if (route.query.tag) {
    const tagName = route.query.tag;
    chain = chain.where(poll => poll.topic().tags.includes(tagName));
  }

  const sortField = sortOrder.value === 'closing_soon' ? 'closingAt' : 'createdAt';
  const sortDesc = sortOrder.value === 'newest';
  return chain.simplesort(sortField, sortDesc).limit(pageSize.value).data();
});

const fetch = () => (
  isLivePendingPolls.value ? loadPendingPolls() : loader.value.fetch(page.value)
);

function emitCurrentComponent() {
  if (group.value) {
    EventBus.$emit('currentComponent', {
      page: 'groupPage',
      title: group.value.name,
      group: group.value
    });
  }
}

initLoader();
fetch().then(emitCurrentComponent);

watch(
  () => [group.value?.id, route.query.status, route.query.poll_type, route.query.tag, route.query.subgroups, route.query.sort, route.query.limit],
  ([nextGroupId], [prevGroupId]) => {
    if (nextGroupId !== prevGroupId) { emitCurrentComponent(); }
    initLoader();
    fetch();
  }
);

watch(() => route.query.page, fetch);
</script>

<template lang="pug">
.polls-panel
  loading(v-if="!dashboard && !group")
  div(v-if="dashboard || group")
    .d-flex.align-center.flex-wrap.ga-2.pt-4.pb-2
      subgroups-filter-menu(v-if="group" :group="group" :selected="subgroupsFilter" @select="selectSubgroups")
      v-menu
        template(v-slot:activator="{ props }")
          v-btn.polls-panel__status-filter.text-medium-emphasis(v-bind="props" variant="tonal")
            span(v-if="effectiveStatus == 'active'") {{ t('polls_panel.open') }}
            span(v-if="effectiveStatus == 'closed'") {{ t('polls_panel.closed') }}
            span(v-if="effectiveStatus == 'vote'") {{ t('polls_panel.need_vote') }}
            span(v-if="!effectiveStatus") {{ t('polls_panel.any_status') }}
            common-icon(name="mdi-menu-down")
        v-list
          v-list-item.polls-panel__status-any(:to="mergeQuery({status: defaultStatus ? '' : null })") {{ t('polls_panel.any_status') }}
          v-list-item.polls-panel__status-active(:to="mergeQuery({status: 'active'})") {{ t('polls_panel.open') }}
          v-list-item.polls-panel__status-closed(:to="mergeQuery({status: 'closed'})") {{ t('polls_panel.closed') }}
          v-list-item.polls-panel__status-vote(:to="mergeQuery({status: 'vote'})") {{ t('polls_panel.need_vote') }}
      v-menu
        template(v-slot:activator="{ props }")
          v-btn.polls-panel__type-filter.text-medium-emphasis(v-bind="props" variant="tonal")
            span(v-if="route.query.poll_type") {{ t('poll_types.' + route.query.poll_type) }}
            span(v-if="!route.query.poll_type") {{ t('polls_panel.any_type') }}
            common-icon(name="mdi-menu-down")
        v-list
          v-list-item.polls-panel__type-any(:to="mergeQuery({poll_type: null})")
            v-list-item-title {{ t('polls_panel.any_type') }}
          v-list-item.polls-panel__type-option(
            v-for="pollType in Object.keys(pollTypes)"
            :key="pollType"
            :data-poll-type="pollType"
            :to="mergeQuery({poll_type: pollType})"
          )
            v-list-item-title {{ t('poll_types.' + pollType) }}
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
      v-btn.polls-panel__new-poll-button(
        v-if="canStartPoll"
        color="primary"
        variant="elevated"
        @click="startNewPoll"
      )
        span {{ t('polls_panel.new_poll') }}
    v-card(variant="flat")
      div(v-if="loader.status == 403")
        p.pa-4.text-center {{ t('error_page.forbidden') }}
      div(v-else)
        v-list(lines="two" v-if="polls.length")
          poll-common-preview(
            :poll="poll"
            v-for="poll in polls"
            :key="poll.id"
            :display-group-name="dashboard || includeSubgroups"
            :full-name="dashboard")
        p.pa-4.text-center(v-if="polls.length == 0 && !isLoading") {{ effectiveStatus === 'vote' ? t('dashboard_page.no_polls_to_vote_on') : t('polls_panel.no_polls') }}
        loading(v-if="isLoading && polls.length == 0")
    list-pagination(
      v-if="polls.length && !isLivePendingPolls && loader.status != 403"
      :page="page"
      :total-pages="totalPages"
      :page-size="pageSize"
      :sort="sortOrder"
      :sort-options="sortOptions"
      :disabled="loader.loading"
      @update:page="page = $event"
      @update:page-size="selectPageSize"
      @update:sort="selectSort"
    )
</template>
