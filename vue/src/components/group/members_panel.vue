<script setup>
import { computed, onUnmounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import Records from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import RecordLoader from '@/shared/services/record_loader';
import Session from '@/shared/services/session';
import EventBus from '@/shared/services/event_bus';
import { debounce, identity, intersection, map, pickBy } from 'lodash-es';
import LmoUrlService from '@/shared/services/lmo_url_service';
import { mdiMagnify } from '@mdi/js';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { group } = defineProps({
  group: {type: Object, required: true}
});
const route = useRoute();
const router = useRouter();
const { t } = useI18n();
const { watchRecords } = useWatchRecords();
const per = 25;
const order = 'created_at desc';
const memberships = ref([]);
const loader = ref(new RecordLoader({
  collection: 'memberships',
  params: {
    exclude_types: 'group',
    group_id: group.id,
    per,
    order,
    subgroups: route.query.subgroups
  }
}));
const canAddMembers = computed(() => AbilityService.canAddMembersToGroup(group));
const showAdminWarning = computed(() =>
  group.adminsInclude(Session.user()) &&
  group.adminMembershipsCount < 2 &&
  group.membershipsCount - group.adminMembershipsCount > 0
);

function mergeQuery(values) {
  return {query: pickBy({...route.query, ...values}, identity)};
}

function routeFor(model, action, params) {
  return LmoUrlService.route({model, action, params});
}

const onQueryInput = debounce(value => router.replace(mergeQuery({q: value})), 500);

function query() {
  let chain = Records.memberships.collection.chain();
  switch (route.query.subgroups) {
    case 'mine':
      chain = chain.find({groupId: {$in: intersection(group.organisationIds(), Session.user().groupIds())}});
      break;
    case 'all':
      chain = chain.find({groupId: {$in: group.organisationIds()}});
      break;
    default:
      chain = chain.find({groupId: group.id});
  }

  chain = chain.sort((a, b) => {
    if (a.groupId === group.id) return -1;
    if (b.groupId === group.id) return 1;
    return 0;
  });

  const userIdsSeen = [];
  const membershipIds = [];
  chain.data().forEach(membership => {
    if (!userIdsSeen.includes(membership.userId)) {
      userIdsSeen.push(membership.userId);
      membershipIds.push(membership.id);
    }
  });
  chain = Records.memberships.collection.chain().find({id: {$in: membershipIds}});

  if (route.query.q) {
    const searchQuery = route.query.q;
    const users = Records.users.collection.find({
      $or: [
        {name: {$regex: [`^${searchQuery}`, 'i']}},
        {email: {$regex: [`${searchQuery}`, 'i']}},
        {username: {$regex: [`^${searchQuery}`, 'i']}},
        {name: {$regex: [` ${searchQuery}`, 'i']}}
      ]
    });
    const userIds = map(users, 'id');
    chain = chain.where(membership =>
      userIds.includes(membership.userId) ||
      (membership.title || '').toLowerCase().includes(searchQuery.toLowerCase())
    );
  }

  switch (route.query.filter) {
    case 'admin': chain = chain.find({admin: true}); break;
    case 'delegate': chain = chain.find({delegate: true}); break;
    case 'accepted': chain = chain.find({acceptedAt: {$ne: null}}); break;
    case 'pending': chain = chain.find({acceptedAt: null}); break;
  }

  memberships.value = chain.simplesort('id', true).data();
}

function refresh() {
  loader.value.fetchRecords({
    from: 0,
    q: route.query.q,
    order,
    filter: route.query.filter,
    subgroups: route.query.subgroups
  });
  query();
}

function openShareableLinkForm() {
  EventBus.$emit('openModal', {
    component: 'GroupShareableLinkForm',
    props: {group}
  });
}

function invite() {
  EventBus.$emit('openModal', {
    component: 'GroupInvitationForm',
    props: {group}
  });
}

EventBus.$emit('currentComponent', {
  page: 'groupPage',
  title: group.name,
  group,
  search: {placeholder: t('navbar.search_members', {name: group.parentOrSelf().name})}
});
watchRecords({collections: ['memberships', 'groups'], query});
watch(() => route.query, refresh);
onUnmounted(() => onQueryInput.cancel());
refresh();
</script>

<template lang="pug">
.members-panel
  loading(v-if="!group")
  div(v-if="group")
    v-alert.my-4(v-if="showAdminWarning" color="info" type="info" variant="tonal")
      span(v-t="'memberships_page.only_one_admin'")

    .d-flex.align-center.flex-wrap.pt-4.pb-2
      v-menu
        template(v-slot:activator="{ props }")
          v-btn.members-panel__filters.mr-2.text-capitalize.text-medium-emphasis(v-bind="props" variant="tonal")
            span(v-if="$route.query.filter == 'admin'" v-t="'members_panel.order_by_admin_desc'")
            span(v-if="$route.query.filter == 'delegate'" v-t="'members_panel.delegates'")
            span(v-if="$route.query.filter == 'pending'" v-t="'members_panel.invitations'")
            span(v-if="$route.query.filter == 'accepted'" v-t="'members_panel.accepted'")
            span(v-if="!$route.query.filter" v-t="'members_panel.all'")
            common-icon(name="mdi-menu-down")
        v-list
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: null})")
            v-list-item-title(v-t="'members_panel.all'")
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: 'accepted'})")
            v-list-item-title(v-t="'members_panel.accepted'")
          v-list-item.members-panel__filters-admins(:to="mergeQuery({filter: 'admin'})")
            v-list-item-title(v-t="'members_panel.order_by_admin_desc'")
          v-list-item.members-panel__filters-delegates(:to="mergeQuery({filter: 'delegate'})")
            v-list-item-title(v-t="'members_panel.delegates'")
          v-list-item.members-panel__filters-invitations(:to="mergeQuery({filter: 'pending'})")
            v-list-item-title(v-t="'members_panel.invitations'")
      v-text-field.mr-2(
        clearable
        hide-details
        variant="solo"
        density="compact"
        @update:model-value="onQueryInput"
        :placeholder="$t('navbar.search_members_short')"
        :prepend-inner-icon="mdiMagnify")
      v-btn.membership-card__invite.mr-2(
        color="primary"
        variant="elevated"
        v-if='canAddMembers'
        @click="invite()"
      )
        span(v-t="'common.action.invite'")
      v-btn.members-panel__shareable-link-btn(v-if='canAddMembers' color="primary" variant="tonal" @click="openShareableLinkForm()")
        span(v-t="'members_panel.sharable_link'")
      v-btn.group-page__requests-tab.text-medium-emphasis.ml-2(
        v-if='group.isVisibleToPublic && canAddMembers'
        :to="routeFor(group, 'membership_requests')"
        variant="text"
      )
        span(v-t="'members_panel.requests'")

    v-card(variant="flat")
      div(v-if="loader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")
      div(v-else)
        p.pa-4.text-center(v-if="!memberships.length" v-t="'common.no_results_found'")
        v-list(v-else lines="two")
          v-list-item(v-for="membership in memberships" :key="membership.id")
            template(v-slot:prepend)
              user-avatar.mr-2(:user='membership.user()' :size='36')
            v-list-item-title
              template(v-if="membership.acceptedAt")
                router-link.text-medium-emphasis.text-decoration-none(:to="routeFor(membership.user())") {{ membership.user().name }}
                span.text-medium-emphasis(v-if="membership.acceptedAt && membership.userEmail")
                  space
                  span &lt;{{membership.userEmail}}&gt;
              template(v-if="!membership.acceptedAt && membership.userEmail")
                | {{membership.userEmail}}

              span.text-body-small(v-if="$route.query.subgroups")
                space
                span {{membership.group().name}}

              template(v-if="membership.user().title(group)")
                space
                span.text-body-small {{membership.user().title(group)}}

              template(v-if="membership.user().bot")
                space
                v-chip(v-if="membership.user().bot" size="x-small" label)
                  span(v-t="'members_panel.bot'")

              template(v-if="membership.user().complaintsCount || membership.user().bouncesCount")
                space
                v-chip(color="error" size="x-small" label :title="$t('members_panel.email_rejected_meaning')")
                  span(v-t="'members_panel.email_rejected'")

              template(v-if="membership.groupId == group.id && membership.admin")
                space
                v-chip(variant="tonal" size="x-small" label)
                  span(v-t="'members_panel.admin'")

              template(v-if="membership.groupId == group.id && membership.delegate")
                space
                v-chip(variant="tonal" size="x-small" label :title="$t('members_panel.delegate_popover')")
                  span(v-t="'members_panel.delegate'" )

            v-list-item-subtitle
              span(v-if="membership.acceptedAt")
                span(v-t="'common.action.joined'")
                space
                time-ago(:date="membership.acceptedAt")
              span(v-else)
                template(v-if="membership.inviterId")
                  span(v-t="{path: 'members_panel.invited_by_name', args: {name: membership.inviter().name}}")
                  space
                  time-ago(:date="membership.createdAt")
                template(v-if="!membership.inviterId")
                  span(v-t="'members_panel.header_invited'")
                  space
                  time-ago(:date="membership.createdAt")

            template(v-slot:append)
              membership-dropdown(v-if="membership.groupId == group.id" :membership="membership")

        .d-flex.justify-center
          .d-flex.flex-column.align-center
            .text-medium-emphasis(v-if='$route.query.subgroups == "all"')
              | {{memberships.length}} / {{group.orgMembersCount}}
            .text-medium-emphasis(v-else)
              | {{memberships.length}} / {{loader.total}}
            v-btn.my-2.members-panel__show-more(variant="tonal" color='primary' v-if="memberships.length < loader.total && !loader.exhausted" :loading="loader.loading" @click="loader.fetchRecords({per: 50})")
              span(v-t="'common.action.load_more'")
            a.text-medium-emphasis.text-decoration-none(v-if='group.subgroupsCount && $route.query.subgroups != "all"' href="?subgroups=all" v-t="'members_panel.show_users_in_subgroups'")

</template>
