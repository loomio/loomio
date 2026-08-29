<script setup>
import { computed, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import AppConfig from '@/shared/services/app_config';
import AbilityService from '@/shared/services/ability_service';
import Records from '@/shared/services/records';
import PageLoader from '@/shared/services/page_loader';
import EventBus from '@/shared/services/event_bus';
import Session from '@/shared/services/session';
import { identity, intersection, pickBy, uniq } from 'lodash-es';
import { mdiMagnify } from '@mdi/js';
import TagsFilterMenu from '@/components/tags/filter_menu';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { group } = defineProps({
  group: {type: Object, required: true}
});
const route = useRoute();
const router = useRouter();
const { watchRecords } = useWatchRecords();
const polls = ref([]);
const loader = ref(null);
const pollTypes = AppConfig.pollTypes;
const per = 25;
const dummyQuery = ref(null);
const page = computed({
  get: () => parseInt(route.query.page) || 1,
  set: value => router.replace({query: {...route.query, page: value}})
});
const totalPages = computed(() => Math.max(1, Math.ceil((loader.value?.total || 0) / per)));
const canStartPoll = computed(() => AbilityService.canStartPoll(group));

function mergeQuery(values) {
  return {query: pickBy({...route.query, ...values}, identity)};
}

function startNewPoll() {
  router.push(`/p/new?group_id=${group.id}`);
}

function selectTag(tag) {
  router.replace(mergeQuery({tag, page: null}));
}

function openSearchModal() {
  const initialOrgId = group.isParent() ? group.id : group.parentId;
  const initialGroupId = group.isParent() ? null : group.id;

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
}

function initLoader() {
  loader.value = new PageLoader({
    path: 'polls',
    order: 'createdAt',
    params: {
      exclude_types: 'group reaction',
      group_key: route.params.key,
      status: route.query.status,
      poll_type: route.query.poll_type,
      tags: route.query.tag,
      subgroups: route.query.subgroups,
      per
    }
  });
}

function fetch() {
  return loader.value.fetch(page.value).then(findRecords);
}

function findRecords() {
  const groupIds = (() => {
    switch (route.query.subgroups || 'mine') {
      case 'all': return group.organisationIds();
      case 'none': return [group.id];
      case 'mine': return uniq([group.id].concat(intersection(group.organisationIds(), Session.user().groupIds())));
    }
  })();

  let chain = Records.polls.collection.chain()
    .find({groupId: {$in: groupIds}})
    .find({discardedAt: null});

  switch (route.query.status) {
    case 'active': chain = chain.find({closedAt: null}); break;
    case 'closed': chain = chain.find({closedAt: {$ne: null}}); break;
    case 'vote': chain = chain.find({closedAt: null}).where(poll => poll.iCanVote() && !poll.iHaveVoted()); break;
  }

  if (route.query.poll_type) chain = chain.find({pollType: route.query.poll_type});
  if (route.query.tag) chain = chain.where(poll => poll.topic().tags.includes(route.query.tag));

  const pageWindow = loader.value.pageWindow[page.value];
  if (!pageWindow) {
    polls.value = [];
    return;
  }

  chain = page.value === 1
    ? chain.find({createdAt: {$gte: pageWindow[0]}})
    : chain.find({createdAt: {$jbetween: pageWindow}});
  polls.value = chain.simplesort('createdAt', true).data();
}

initLoader();
watchRecords({
  collections: ['polls', 'groups', 'stances'],
  query: findRecords
});
watch(
  () => [route.query.status, route.query.poll_type, route.query.tag, route.query.subgroups],
  () => {
    initLoader();
    fetch();
  }
);
watch(() => route.query.page, fetch);
fetch().then(() => {
  EventBus.$emit('currentComponent', {
    page: 'groupPage',
    title: group.name,
    group
  });
});
</script>

<template lang="pug">
.polls-panel
  loading(v-if="!group")
  div(v-if="group")
    .d-flex.align-center.flex-wrap.pt-4.pb-2
      v-menu
        template(v-slot:activator="{ props }")
          v-btn.mr-2.text-medium-emphasis(v-bind="props" variant="tonal")
            span(v-if="$route.query.status == 'active'" v-t="'polls_panel.open'")
            span(v-if="$route.query.status == 'closed'" v-t="'polls_panel.closed'")
            span(v-if="$route.query.status == 'vote'" v-t="'polls_panel.need_vote'")
            span(v-if="!$route.query.status" v-t="'polls_panel.any_status'")
            common-icon(name="mdi-menu-down")
        v-list
          v-list-item(:to="mergeQuery({status: null })" v-t="'polls_panel.any_status'")
          v-list-item(:to="mergeQuery({status: 'active'})" v-t="'polls_panel.open'")
          v-list-item(:to="mergeQuery({status: 'closed'})" v-t="'polls_panel.closed'")
          v-list-item(:to="mergeQuery({status: 'vote'})" v-t="'polls_panel.need_vote'")
      v-menu
        template(v-slot:activator="{ props }")
          v-btn.mr-2.text-medium-emphasis(v-bind="props" variant="tonal")
            span(v-if="$route.query.poll_type" v-t="'poll_types.'+$route.query.poll_type")
            span(v-if="!$route.query.poll_type" v-t="'polls_panel.any_type'")
            common-icon(name="mdi-menu-down")
        v-list
          v-list-item(:to="mergeQuery({poll_type: null})" )
            v-list-item-title(v-t="'polls_panel.any_type'")
          v-list-item(
            v-for="pollType in Object.keys(pollTypes)"
            :key="pollType"
            :to="mergeQuery({poll_type: pollType})"
          )
            v-list-item-title(v-t="'poll_types.'+pollType")
      tags-filter-menu(:group="group" :selected-tag="$route.query.tag" @select="selectTag")
      v-btn.text-medium-emphasis(
        variant="tonal"
        @click="openSearchModal"
      )
        common-icon.mr-1(name="mdiMagnify")
        span(v-t="'common.action.search'")
      v-spacer
      v-btn.polls-panel__new-poll-button(
        v-if='canStartPoll'
        color="primary"
        variant="elevated"
        @click="startNewPoll"
      )
        span(v-t="'polls_panel.new_poll'")
    v-card(variant="flat")
      div(v-if="loader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")
      div(v-else)
        v-list(lines="two" v-if='polls.length && loader.pageWindow[page]')
          poll-common-preview(
            :poll='poll'
            v-for='poll in polls'
            :key='poll.id'
            :display-group-name="poll.groupId != group.id")
        p.pa-4.text-center(v-if='polls.length == 0 && !loader.loading' v-t="'polls_panel.no_polls'")
        loading(v-if="loader.loading")
        v-pagination(v-model="page" :length="totalPages" :total-visible="7" :disabled="totalPages == 1")

</template>
