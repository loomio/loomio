<script lang="js">
export function syncSearchFromQuery(state, q) {
  const next = q || '';
  if (next !== state.searchQueryPushed) {
    state.searchQueryPushed = next;
    state.searchQuery = next;
    if (next) { state.searchOpen = true; }
  }
}
</script>

<script setup lang="js">
import { computed, nextTick, reactive, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { intersection, debounce, identity, map, pickBy, uniq } from 'lodash-es';
import { mdiClose, mdiMagnify } from '@mdi/js';
import Records from '@/shared/services/records';
import GroupAbility from '@/shared/abilities/group_ability';
import PageLoader from '@/shared/services/page_loader';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import LmoUrlService from '@/shared/services/lmo_url_service';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';
import ListPagination from '@/components/common/list_pagination.vue';

const route = useRoute();
const router = useRouter();
const { t } = useI18n();

const group = ref(null);
const loader = ref(null);
const memberSearch = ref(null);

const pageSize = computed(() => {
  const n = parseInt(route.query.limit, 10);
  return [25, 50, 100].includes(n) ? n : 25;
});

const searchState = reactive({
  searchOpen: Boolean(route.query.q),
  searchQuery: route.query.q || '',
  searchQueryPushed: route.query.q || ''
});

function urlFor(model, action, params) {
  return LmoUrlService.route({ model, action, params });
}

function mergeQuery(obj) {
  return { query: pickBy(Object.assign({}, route.query, obj), identity) };
}

const subgroupsFilter = computed(() => {
  if (!group.value || !(group.value.subgroupsCount > 0)) { return null; }
  return ['mine', 'all'].includes(route.query.subgroups) ? route.query.subgroups : null;
});

const sortOrder = computed(() => (
  ['oldest', 'name', 'last_seen'].includes(route.query.sort) ? route.query.sort : 'newest'
));

const sortOptions = computed(() => [
  { value: 'newest', label: t('pagination.sort.newest') },
  { value: 'oldest', label: t('pagination.sort.oldest') },
  { value: 'name', label: t('pagination.sort.name') },
  { value: 'last_seen', label: t('pagination.sort.last_seen') }
]);

const page = computed({
  get: () => parseInt(route.query.page) || 1,
  set: (val) => router.replace(mergeQuery({ page: val === 1 ? null : val }))
});

const totalPages = computed(() => Math.max(1, Math.ceil((loader.value?.total || 0) / pageSize.value)));

function createLoader() {
  if (!group.value) { return; }
  loader.value = new PageLoader({
    path: 'memberships',
    order: 'createdAt',
    params: {
      exclude_types: 'group',
      group_id: group.value.id,
      limit: pageSize.value,
      q: route.query.q || undefined,
      filter: route.query.filter || undefined,
      subgroups: subgroupsFilter.value || undefined,
      sort: sortOrder.value === 'newest' ? undefined : sortOrder.value
    }
  });
}

function fetchPage() {
  if (!loader.value) { return; }
  loader.value.fetch(page.value);
}

function refresh() {
  if (!group.value) { return; }
  createLoader();
  fetchPage();
}

function selectSubgroups(val) {
  router.replace(mergeQuery({ subgroups: val, page: null }));
}

function selectSort(val) {
  router.replace(mergeQuery({ sort: val === 'newest' ? null : val, page: null }));
}

function selectPageSize(val) {
  router.replace(mergeQuery({ limit: val === 25 ? null : val, page: null }));
}

function openSearch() {
  searchState.searchOpen = true;
  nextTick(() => memberSearch.value?.focus());
}

function closeSearch() {
  searchState.searchOpen = false;
  searchState.searchQuery = '';
  searchState.searchQueryPushed = '';
  if (route.query.q) {
    router.replace(mergeQuery({ q: null, page: null }));
  }
}

const onQueryInput = debounce(val => {
  searchState.searchQueryPushed = val || '';
  return router.replace(mergeQuery({ q: val || null, page: null }));
}, 400);

function invite() {
  const allowed = Session.user().emailInvitationsAllowed() || group.value.emailInvitationsAllowed();
  const component = allowed ? 'GroupInvitationForm' : 'GroupShareableLinkForm';
  EventBus.$emit('openModal', {
    component,
    props: { group: group.value }
  });
}

function initGroup() {
  const cached = typeof Records.groups.fuzzyFind === 'function' ? Records.groups.fuzzyFind(route.params.key) : null;
  if (cached) { group.value = cached; }

  Records.groups.findOrFetch(route.params.key).then(fetched => {
    group.value = fetched;

    EventBus.$emit('currentComponent', {
      page: 'groupPage',
      title: group.value.name,
      group: group.value,
      search: {
        placeholder: t('navbar.search_members', { name: group.value.parentOrSelf().name })
      }
    });

    refresh();
  }).catch(() => {
    // GroupPage owns route-level group fetch error handling.
  });
}

initGroup();

const memberships = computed(() => {
  if (!group.value) { return []; }

  const pageIds = loader.value?.pageIds?.[page.value];
  if (Array.isArray(pageIds)) {
    return pageIds
      .map(id => Records.memberships.findById(id))
      .filter(m => m && !m.revokedAt);
  }

  if (page.value !== 1 || !loader.value?.loading) {
    return [];
  }

  let groupFilter = group.value.id;
  if (subgroupsFilter.value === 'all') {
    groupFilter = { $in: group.value.organisationIds() };
  } else if (subgroupsFilter.value === 'mine') {
    groupFilter = { $in: uniq([group.value.id].concat(intersection(group.value.organisationIds(), Session.user().groupIds()))) };
  }
  let chain = Records.memberships.collection.chain().find({ revokedAt: null, groupId: groupFilter });

  const userIds = [];
  const membershipIds = [];
  chain.data().forEach(m => {
    if (!userIds.includes(m.userId)) {
      userIds.push(m.userId);
      membershipIds.push(m.id);
    }
  });

  chain = Records.memberships.collection.chain().find({ id: { $in: membershipIds } });

  if (route.query.q) {
    const query = route.query.q;
    const users = Records.users.collection.find({
      $or: [
        { name: { $regex: [`^${query}`, 'i'] } },
        { email: { $regex: [`${query}`, 'i'] } },
        { username: { $regex: [`^${query}`, 'i'] } },
        { name: { $regex: [` ${query}`, 'i'] } }
      ]
    });
    const matchedUserIds = map(users, 'id');

    chain = chain.where(membership => (
      matchedUserIds.includes(membership.userId) ||
      (membership.title || '').toLowerCase().includes(query.toLowerCase())
    ));
  }

  switch (route.query.filter) {
    case 'admin':
      chain = chain.find({ admin: true });
      break;
    case 'delegate':
      chain = chain.find({ delegate: true });
      break;
    case 'accepted':
      chain = chain.find({ acceptedAt: { $ne: null } });
      break;
    case 'pending':
      chain = chain.find({ acceptedAt: null });
      break;
  }

  const results = chain.data();
  const memberTimestamp = m => (m.acceptedAt || m.createdAt || 0);
  switch (sortOrder.value) {
    case 'oldest':
      results.sort((a, b) => memberTimestamp(a) - memberTimestamp(b));
      break;
    case 'name':
      results.sort((a, b) => (a.user()?.name || '').localeCompare(b.user()?.name || ''));
      break;
    case 'last_seen':
      results.sort((a, b) => (b.user()?.lastSeenAt || 0) - (a.user()?.lastSeenAt || 0));
      break;
    default:
      results.sort((a, b) => memberTimestamp(b) - memberTimestamp(a));
      break;
  }
  return results.slice(0, pageSize.value);
});

const canAddMembers = computed(() => GroupAbility.canAddMembers(group.value));
const canManageWeights = computed(() => GroupAbility.canUpdate(group.value));
const showAdminWarning = computed(() => (
  group.value.adminsInclude(Session.user()) &&
  (group.value.adminMembershipsCount < 2) &&
  ((group.value.membershipsCount - group.value.adminMembershipsCount) > 0)
));

// Only take the search from the URL when navigation changed it. The URL
// update this box pushed can arrive after more typing, and must not undo it.
watch(
  () => [route.query.q, route.query.filter, route.query.subgroups, route.query.sort, route.query.limit],
  () => {
    syncSearchFromQuery(searchState, route.query.q);
    refresh();
  }
);

watch(() => route.query.page, fetchPage);
watch(() => route.params.key, initGroup);
</script>

<template lang="pug">
.members-panel
  loading(v-if="!group")
  div(v-if="group")
    v-alert.my-4(v-if="showAdminWarning" color="info" type="info" variant="tonal")
      span {{ t('memberships_page.only_one_admin') }}

    .d-flex.align-center.flex-wrap.ga-2.pt-4.pb-2
      subgroups-filter-menu(:group="group" :selected="subgroupsFilter" @select="selectSubgroups")
      v-menu
        template(v-slot:activator="{ props }")
          v-btn.members-panel__filters.text-capitalize.text-medium-emphasis(v-bind="props" variant="tonal")
            span(v-if="route.query.filter == 'admin'") {{ t('members_panel.order_by_admin_desc') }}
            span(v-else-if="route.query.filter == 'delegate'") {{ t('members_panel.delegates') }}
            span(v-else-if="route.query.filter == 'pending'") {{ t('members_panel.invitations') }}
            span(v-else-if="route.query.filter == 'accepted'") {{ t('members_panel.accepted') }}
            span(v-else) {{ t('members_panel.all') }}
            common-icon(name="mdi-menu-down")
        v-list
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: null, page: null})")
            v-list-item-title {{ t('members_panel.all') }}
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: 'accepted', page: null})")
            v-list-item-title {{ t('members_panel.accepted') }}
          v-list-item.members-panel__filters-admins(:to="mergeQuery({filter: 'admin', page: null})")
            v-list-item-title {{ t('members_panel.order_by_admin_desc') }}
          v-list-item.members-panel__filters-delegates(:to="mergeQuery({filter: 'delegate', page: null})")
            v-list-item-title {{ t('members_panel.delegates') }}
          v-list-item.members-panel__filters-invitations(:to="mergeQuery({filter: 'pending', page: null})")
            v-list-item-title {{ t('members_panel.invitations') }}
      v-tooltip(v-if="!searchState.searchOpen" location="bottom" :text="t('navbar.search_members_short')")
        template(#activator="{ props }")
          v-btn.members-panel__search-button.text-medium-emphasis(
            v-bind="props"
            icon
            density="comfortable"
            variant="tonal"
            :aria-label="t('navbar.search_members_short')"
            @click="openSearch"
          )
            common-icon(name="mdi-magnify")
      v-text-field(
        v-if="searchState.searchOpen"
        ref="memberSearch"
        v-model="searchState.searchQuery"
        hide-details
        variant="solo"
        density="compact"
        @update:model-value="onQueryInput"
        :placeholder="t('navbar.search_members_short')"
        :prepend-inner-icon="mdiMagnify"
        :append-inner-icon="mdiClose"
        @click:append-inner="closeSearch"
        @keyup.esc="closeSearch"
      )
      v-spacer
      v-btn.membership-card__invite(
        color="primary"
        variant="elevated"
        v-if="canAddMembers"
        @click="invite()"
      )
        span {{ t('common.action.invite') }}
      v-btn.members-panel__edit-weights(v-if="canManageWeights" variant="tonal" :to="urlFor(group, 'members/weights')") {{ t('members_panel.edit_vote_weights') }}
      v-btn.group-page__requests-tab.text-medium-emphasis(
        v-if="group.isVisibleToPublic && canAddMembers"
        :to="urlFor(group, 'membership_requests')"
        variant="text"
      )
        span {{ t('members_panel.requests') }}

    v-card(variant="flat")
      div(v-if="loader && loader.status == 403")
        p.pa-4.text-center {{ t('error_page.forbidden') }}
      div(v-else)
        loading(v-if="loader && loader.loading && !memberships.length")
        p.pa-4.text-center(v-else-if="!memberships.length") {{ t('common.no_results_found') }}
        v-list(v-else lines="two")
          v-list-item.members-panel__member(v-for="membership in memberships" :key="membership.id")
            template(v-slot:prepend)
              user-avatar.mr-2(:user="membership.user()" :size="36")
            v-list-item-title
              template(v-if="membership.acceptedAt")
                router-link.text-medium-emphasis.text-decoration-none(:to="urlFor(membership.user())") {{ membership.user().name }}
                span.text-medium-emphasis(v-if="membership.acceptedAt && membership.userEmail")
                  space
                  span &lt;{{ membership.userEmail }}&gt;
              template(v-if="!membership.acceptedAt && membership.userEmail")
                | {{ membership.userEmail }}

              template(v-if="membership.user().title(group)")
                space
                span.text-body-small {{ membership.user().title(group) }}

              template(v-if="membership.user().bot")
                space
                v-chip(v-if="membership.user().bot" size="x-small" label)
                  span {{ t('members_panel.bot') }}

              template(v-if="membership.groupId == group.id && membership.admin")
                space
                v-chip(variant="tonal" size="x-small" label)
                  span {{ t('members_panel.admin') }}

              template(v-if="membership.groupId == group.id && membership.delegate")
                space
                v-chip(variant="tonal" size="x-small" label :title="t('members_panel.delegate_popover')")
                  span {{ t('members_panel.delegate') }}

            v-list-item-subtitle
              span(v-if="membership.acceptedAt")
                span {{ t('common.action.joined') }}
                space
                time-ago(:date="membership.acceptedAt")
              span(v-else)
                template(v-if="membership.inviterId")
                  span {{ t('members_panel.invited_by_name', { name: membership.inviter().name }) }}
                  space
                  time-ago(:date="membership.createdAt")
                template(v-if="!membership.inviterId")
                  span {{ t('members_panel.header_invited') }}
                  space
                  time-ago(:date="membership.createdAt")

            template(v-slot:append)
              membership-dropdown(v-if="membership.groupId == group.id" :membership="membership")

        list-pagination(
          v-if="loader && memberships.length"
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
