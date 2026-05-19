<script setup lang="js">
import PageLoader         from '@/shared/services/page_loader';
import Records from '@/shared/services/records';
import { debounce } from 'lodash-es';
import { I18n } from '@/i18n';
import ScrollService from '@/shared/services/scroll_service';
import { computed, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';

const props = defineProps({
  poll: Object
});

const route = useRoute();
const router = useRouter();

const stances = ref([]);
const per = 50;
const loader = ref(null);
const page = ref(parseInt(route.query.page) || 1);
const name = ref(route.query.name);
const castFilter = 'cast';
const uncastFilter = 'uncast';

function initialVoteFilter() {
  const pollOptionId = parseInt(route.query.poll_option_id);
  if (!Number.isNaN(pollOptionId)) { return pollOptionId; }

  return route.query.stance_filter === uncastFilter ? uncastFilter : castFilter;
}

const voteFilter = ref(initialVoteFilter());
const selectedPollOptionId = computed(() => {
  return typeof voteFilter.value === 'number' ? voteFilter.value : null;
});
const selectedStanceFilter = computed(() => {
  return voteFilter.value === uncastFilter ? uncastFilter : castFilter;
});

const pollOptionItems = computed(() => {
  const items = [
    {title: I18n.global.t('poll_common_votes_panel.cast'), value: castFilter},
    {title: I18n.global.t('poll_common_votes_panel.uncast'), value: uncastFilter}
  ];

  if (!props.poll.showResults()) { return items; }

  return items.concat(props.poll.pollOptions().map(o => {
    return {title: o.optionName(), value: o.id};
  }));
});

const totalPages = computed(() => {
  return Math.max(1, Math.ceil(((loader.value && loader.value.total) || 0) / per));
});

function findRecords() {
  if (loader.value.pageWindow[page.value]) {
    let chain = Records.stances.collection.chain().find({id: {$in: loader.value.pageIds[page.value]}});
    chain = chain.simplesort('orderAt', true);
    stances.value = chain.data();
  } else {
    stances.value = [];
  }
}

function fetchNow() {
  loader.value = new PageLoader({
    path: 'stances',
    order: 'orderAt',
    params: {
      per,
      poll_id: props.poll.id,
      poll_option_id: selectedPollOptionId.value,
      stance_filter: selectedStanceFilter.value,
      name: name.value
    }
  });
  loader.value.fetch(page.value).then(findRecords).then(() => ScrollService.scrollTo('#votes'));
}

const fetch = debounce(function() {
  fetchNow();
} , 50);

watch(page, (val, lastVal) => {
  if (val === lastVal) { return; }
  router.replace({query: Object.assign({}, route.query, {page: val})});
  fetch();
});

watch(voteFilter, (val, lastVal) => {
  if (val === lastVal) { return; }
  page.value = 1;
  name.value = null;
  router.replace({query: Object.assign({}, route.query, {
    page: null,
    poll_option_id: selectedPollOptionId.value,
    stance_filter: selectedStanceFilter.value,
    name: null
  })});
  fetch();
});

watch(name, (val, lastVal) => {
  if (val === lastVal) { return; }
  page.value = 1;
  router.replace({query: Object.assign({}, route.query, {page: null, name: val || null})});
  fetch();
});

fetchNow();

</script>

<template lang="pug">
.poll-common-votes-panel
  h2.text-h5.my-2#votes(v-t="'poll_common.votes'")
  .d-flex
    v-select.mr-2(:items="pollOptionItems" :label="$t('common.option')" v-model="voteFilter")
    v-text-field(v-if="!poll.anonymous" v-model="name" :label="$t('poll_common_votes_panel.name_or_username')")
  .poll-common-votes-panel__no-votes.text-medium-emphasis(v-if='!poll.votersCount' v-t="'poll_common_votes_panel.no_votes_yet'")
  .poll-common-votes-panel__has-votes(v-if='poll.votersCount')
    .poll-common-votes-panel__stance(v-for='stance in stances', :key='stance.id')
      .poll-common-votes-panel__avatar.pr-3
        user-avatar(:user='stance.participant()', :size='24')
      .poll-common-votes-panel__stance-content
        .poll-common-votes-panel__stance-name-and-option
          v-layout.text-body-2(align-center)
            span.text-medium-emphasis {{ stance.participantName() }}
            span(v-if="poll.showResults() && stance.castAt && poll.hasOptionIcon()")
              poll-common-stance-choice.pl-2.pr-1(
                :poll="poll"
                :stance-choice="stance.stanceChoice()")
              space
            span(v-if='!stance.castAt' )
              space
              span(v-t="'poll_common_votes_panel.undecided'" )
            span(v-if="stance.castAt")
              space
              mid-dot(v-if="!poll.hasOptionIcon()")
              time-ago.text-medium-emphasis(:date="stance.castAt")
        .poll-common-stance(v-if="poll.showResults() && stance.castAt")
          poll-common-stance-choices(:stance='stance')
          formatted-text.poll-common-stance-created__reason(:model="stance" field="reason")
          attachment-list(:attachments="stance.attachments")
    loading(v-if="loader.loading")
    v-pagination(v-if="totalPages > 1" v-model="page", :length="totalPages")
</template>

<style lang="sass">
.poll-common-votes-panel__stance
	display: flex
	align-items: flex-start
	margin: 7px 0

</style>
