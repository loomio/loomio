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
import RecordLoader from '@/shared/services/record_loader';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import LmoUrlService from '@/shared/services/lmo_url_service';
import SubgroupsFilterMenu from '@/components/group/subgroups_filter_menu.vue';

const route = useRoute();
const router = useRouter();
const { t } = useI18n();

const limit = 25;
const order = ref('created_at desc');
const group = ref(null);
const loader = ref(null);
const memberSearch = ref(null);

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

function refresh() {
  if (!loader.value) { return; }
  loader.value.fetchRecords({
    offset: 0,
    q: route.query.q,
    order: order.value,
    filter: route.query.filter,
    subgroups: subgroupsFilter.value || undefined
  });
}

const onQueryInput = debounce(val => {
  searchState.searchQueryPushed = val || '';
  return router.replace(mergeQuery({ q: val }));
}, 500);

function openSearch() {
  searchState.searchOpen = true;
  nextTick(() => memberSearch.value?.focus());
}

function closeSearch() {
  onQueryInput.cancel();
  searchState.searchQuery = '';
  searchState.searchQueryPushed = '';
  searchState.searchOpen = false;
  router.replace(mergeQuery({ q: null }));
}

function selectSubgroups(val) {
  router.replace(mergeQuery({ subgroups: val }));
}

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

    loader.value = new RecordLoader({
      collection: 'memberships',
      params: {
        exclude_types: 'group',
        group_id: group.value.id,
        limit,
        order: order.value,
        subgroups: subgroupsFilter.value || undefined
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

  return chain.simplesort('id', true).data();
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
watch(() => route.query, () => {
  syncSearchFromQuery(searchState, route.query.q);
  refresh();
});

watch(() => route.params.key, initGroup);
</script>

<template lang="pug">
.members-panel
  loading(v-if="!group")
  div(v-if="group")
    v-alert.my-4(v-if="showAdminWarning" color="info" type="info" variant="tonal")
      span {{ t('memberships_page.only_one_admin') }}

    .d-flex.align-center.flex-wrap.pt-4.pb-2
      subgroups-filter-menu.mr-2(:group="group" :selected="subgroupsFilter" @select="selectSubgroups")
      v-menu
        template(v-slot:activator="{ props }")
          v-btn.members-panel__filters.mr-2.text-capitalize.text-medium-emphasis(v-bind="props" variant="tonal")
            span(v-if="route.query.filter == 'admin'") {{ t('members_panel.order_by_admin_desc') }}
            span(v-else-if="route.query.filter == 'delegate'") {{ t('members_panel.delegates') }}
            span(v-else-if="route.query.filter == 'pending'") {{ t('members_panel.invitations') }}
            span(v-else-if="route.query.filter == 'accepted'") {{ t('members_panel.accepted') }}
            span(v-else) {{ t('members_panel.all') }}
            common-icon(name="mdi-menu-down")
        v-list
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: null})")
            v-list-item-title {{ t('members_panel.all') }}
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: 'accepted'})")
            v-list-item-title {{ t('members_panel.accepted') }}
          v-list-item.members-panel__filters-admins(:to="mergeQuery({filter: 'admin'})")
            v-list-item-title {{ t('members_panel.order_by_admin_desc') }}
          v-list-item.members-panel__filters-delegates(:to="mergeQuery({filter: 'delegate'})")
            v-list-item-title {{ t('members_panel.delegates') }}
          v-list-item.members-panel__filters-invitations(:to="mergeQuery({filter: 'pending'})")
            v-list-item-title {{ t('members_panel.invitations') }}
      v-btn.members-panel__search-button.mr-2(
        v-if="!searchState.searchOpen"
        variant="text"
        @click="openSearch"
      )
        v-icon.mr-1(:icon="mdiMagnify")
        span {{ t('navbar.search_members_short') }}
      v-text-field.mr-2(
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
      v-btn.membership-card__invite.mr-2(
        color="primary"
        variant="elevated"
        v-if="canAddMembers"
        @click="invite()"
      )
        span {{ t('common.action.invite') }}
      v-btn.members-panel__edit-weights(v-if="canManageWeights" variant="tonal" :to="urlFor(group, 'members/weights')") {{ t('members_panel.edit_vote_weights') }}
      v-btn.group-page__requests-tab.text-medium-emphasis.ml-2(
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

        .d-flex.justify-center(v-if="loader")
          .d-flex.flex-column.align-center
            .text-medium-emphasis(v-if="loader.total")
              | {{ memberships.length }} / {{ loader.total }}
            v-btn.my-2.members-panel__show-more(
              variant="tonal"
              color="primary"
              v-if="memberships.length < loader.total && !loader.exhausted"
              :loading="loader.loading"
              @click="loader.fetchRecords({ limit: 50 })"
            )
              span {{ t('common.action.load_more') }}
</template>
