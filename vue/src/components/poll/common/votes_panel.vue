<script setup lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import { debounce } from 'lodash-es';
import { computed, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';

const { poll } = defineProps({ poll: Object });
const { t } = useI18n();
const route = useRoute();
const router = useRouter();

const per = 50;
const page = ref(Math.max(1, parseInt(route.query.page, 10) || 1));
const name = ref(route.query.name || '');
const voteFilter = ref(route.query.poll_option_id ? Number(route.query.poll_option_id) : (route.query.stance_filter || 'all'));
const stances = ref([]);
const stancesTotal = ref(0);
const stancesLoading = ref(false);
const voterDetailsByUserId = ref({});
const showVoterDetails = ref(false);
const showVoterEmail = ref(false);
let fetchSequence = 0;
const receipts = ref([]);
const receiptsLoaded = ref(false);
const receiptsMeta = ref(null);
const canVerifyParticipants = AbilityService.canVerifyParticipants(poll);

const pollOptionItems = computed(() => {
  const items = [
    { title: t('poll_common_votes_panel.all_voters'), value: 'all' },
    { title: t('poll_common_votes_panel.cast'), value: 'cast' },
    { title: t('poll_common_votes_panel.uncast'), value: 'uncast' }
  ];
  if (!poll.showResults()) { return items; }
  return items.concat(poll.pollOptions().map(option => ({ title: option.optionName(), value: option.id })));
});

const matchingReceipts = computed(() => {
  const query = (name.value || '').trim().toLocaleLowerCase();
  if (!query) { return receipts.value; }
  return receipts.value.filter(receipt =>
    receipt.voter_name?.toLocaleLowerCase().includes(query) ||
    receipt.voter_email?.toLocaleLowerCase().includes(query)
  );
});
const visibleReceipts = computed(() => matchingReceipts.value.slice((page.value - 1) * per, page.value * per));
const total = computed(() => poll.anonymous ? matchingReceipts.value.length : stancesTotal.value);
const totalPages = computed(() => Math.max(1, Math.ceil(total.value / per)));

async function fetchStances() {
  const sequence = ++fetchSequence;
  const params = { per, poll_id: poll.id };
  if (typeof voteFilter.value === 'number') { params.poll_option_id = voteFilter.value; }
  if (voteFilter.value === 'cast' || voteFilter.value === 'uncast') { params.stance_filter = voteFilter.value; }
  if (name.value) { params.name = name.value; }
  params.from = (page.value - 1) * per;
  stancesLoading.value = true;
  stances.value = [];
  try {
    const data = await Records.fetch({ path: 'stances', params });
    if (sequence !== fetchSequence) { return; }
    if (page.value > Math.max(1, Math.ceil(data.meta.total / per))) {
      page.value = Math.max(1, Math.ceil(data.meta.total / per));
      return;
    }
    const ids = data.stances.map(stance => stance.id);
    const stancesById = new Map(Records.stances.findByIds(ids).map(stance => [stance.id, stance]));
    stances.value = ids.map(id => stancesById.get(id)).filter(Boolean);
    stancesTotal.value = data.meta.total;
    voterDetailsByUserId.value = data.meta.voter_details_by_user_id || {};
    showVoterDetails.value = data.meta.show_voter_details;
    showVoterEmail.value = data.meta.show_voter_email;
  } catch (error) {
    if (sequence === fetchSequence) { EventBus.$emit('pageError', error); }
  } finally {
    if (sequence === fetchSequence) { stancesLoading.value = false; }
  }
}

if (poll.anonymous) {
  if (canVerifyParticipants) {
    Records.fetch({ path: `polls/${poll.id}/receipts` }).then(data => {
      receipts.value = data.receipts;
      receiptsMeta.value = data;
      receiptsLoaded.value = true;
      if (page.value > totalPages.value) { page.value = totalPages.value; }
    }).catch(error => EventBus.$emit('pageError', error));
  }
} else {
  fetchStances();
}

const fetchDebounced = debounce(fetchStances, 100);

watch(page, value => {
  router.replace({ query: { ...route.query, page: value === 1 ? undefined : value } });
  if (!poll.anonymous) { fetchStances(); }
});

watch([name, voteFilter], () => {
  const pageChanged = page.value !== 1;
  if (pageChanged) { page.value = 1; }
  router.replace({ query: {
    ...route.query,
    page: undefined,
    name: name.value || undefined,
    stance_filter: !poll.anonymous && typeof voteFilter.value === 'string' && voteFilter.value !== 'all' ? voteFilter.value : undefined,
    poll_option_id: !poll.anonymous && typeof voteFilter.value === 'number' ? voteFilter.value : undefined
  } });
  if (!poll.anonymous && !pageChanged) { fetchDebounced(); }
});
</script>

<template lang="pug">
.poll-common-votes-panel#votes
  template(v-if="poll.anonymous")
    template(v-if="canVerifyParticipants")
      p.text-medium-emphasis.my-3(v-if="receiptsMeta?.participation_status_visible") {{ t('poll_receipts_page.participation_records_explanation') }}
      p.text-medium-emphasis.my-3(v-else-if="receiptsLoaded") {{ t('poll_receipts_page.participation_status_requires_min_votes', { count: receiptsMeta.participation_status_votes_min }) }}
      p.text-medium-emphasis.my-3(v-if="receiptsMeta?.show_voter_email") {{ t('poll_receipts_page.email_addresses_for_group_admins') }}
      v-alert.my-3(v-if="receiptsLoaded && receiptsMeta.voters_count > 0 && !receipts.length" type="error") {{ t('poll_receipts_page.no_receipts') }}
      v-text-field.poll-common-votes-panel__search.my-3(v-model="name" :label="t('poll_common_votes_panel.name_or_username')" density="compact" hide-details clearable)
      v-table(v-if="receiptsLoaded" density="comfortable")
        thead
          tr
            th
            th {{ t('poll_receipts_page.voter_name') }}
            th(v-if="receiptsMeta.show_voter_email") {{ t('poll_receipts_page.voter_email') }}
            th(v-if="receiptsMeta.participation_status_visible") {{ t('poll_receipts_page.vote_cast') }}
            th {{ t('poll_receipts_page.member_since') }}
            th {{ t('poll_receipts_page.invited_by') }}
            th {{ t('poll_receipts_page.invited_on') }}
        tbody
          tr(v-for="receipt in visibleReceipts" :key="receipt.voter_id")
            td
              v-avatar(:image="receipt.voter_thumb_url" :size="32")
                span(v-if="!receipt.voter_thumb_url") {{ receipt.voter_avatar_initials }}
            td {{ receipt.voter_name }}
            td(v-if="receiptsMeta.show_voter_email") {{ receipt.voter_email }}
            td(v-if="receiptsMeta.participation_status_visible")
              v-icon(
                :icon="receipt.vote_cast ? 'mdi-check' : 'mdi-close'"
                :color="receipt.vote_cast ? 'success' : 'error'"
                size="small"
                :aria-label="t(receipt.vote_cast ? 'poll_receipts_page.voted' : 'poll_receipts_page.not_voted')")
            td {{ receipt.member_since }}
            td {{ receipt.inviter_name }}
            td {{ receipt.invited_on }}
    p.text-medium-emphasis.my-4(v-else) {{ t('poll_common_votes_panel.participation_records_restricted') }}
  template(v-else)
    p.text-medium-emphasis.my-3(v-if="showVoterEmail") {{ t('poll_receipts_page.email_addresses_for_group_admins') }}
    .d-flex.flex-wrap.ga-2.my-3
      v-select.poll-common-votes-panel__filter(:items="pollOptionItems" :label="t('common.option')" v-model="voteFilter" density="compact" hide-details)
      v-text-field.poll-common-votes-panel__search(v-model="name" :label="t('poll_common_votes_panel.name_or_username')" density="compact" hide-details clearable)
    v-table(density="comfortable")
      thead
        tr
          th
          th {{ t('poll_receipts_page.voter_name') }}
          th(v-if="showVoterEmail") {{ t('poll_receipts_page.voter_email') }}
          th {{ t('poll_common_votes_panel.stance') }}
          th(v-if="poll.weightedVoting") {{ t('poll_common_votes_panel.vote_weight_column') }}
          th(v-if="showVoterDetails") {{ t('poll_receipts_page.member_since') }}
          th(v-if="showVoterDetails") {{ t('poll_receipts_page.invited_by') }}
          th(v-if="showVoterDetails") {{ t('poll_receipts_page.invited_on') }}
      tbody
        tr(v-for="stance in stances" :key="stance.id")
          td
            user-avatar(:user="stance.participant()" :size="32")
          td {{ stance.participantName() }}
          td(v-if="showVoterEmail") {{ voterDetailsByUserId[stance.participantId]?.voter_email }}
          td
            template(v-if="!stance.castAt") {{ t('poll_receipts_page.not_voted') }}
            template(v-else-if="!poll.showResults() || !poll.config().has_options") {{ t('poll_receipts_page.voted') }}
            template(v-else-if="stance.sortedChoices().some(choice => choice.show)")
              .d-flex.flex-wrap.ga-2
                template(v-for="choice in stance.sortedChoices().filter(choice => choice.show)" :key="choice.pollOption.id")
                  span
                    span(v-if="choice.rank") {{ choice.rank }}. {{ choice.pollOption.optionName() }}
                    span(v-else) {{ choice.pollOption.optionName() }}
                    span.ml-1(v-if="poll.hasVariableScore() && poll.pollType !== 'ranked_choice'") ({{ choice.score }})
            template(v-else) {{ t('poll_common_form.none_of_the_above') }}
          td(v-if="poll.weightedVoting") {{ stance.weight }}
          td(v-if="showVoterDetails") {{ voterDetailsByUserId[stance.participantId]?.member_since }}
          td(v-if="showVoterDetails") {{ voterDetailsByUserId[stance.participantId]?.inviter_name }}
          td(v-if="showVoterDetails") {{ voterDetailsByUserId[stance.participantId]?.invited_on }}
    loading(v-if="stancesLoading")
  p.text-medium-emphasis.my-4(v-if="!stancesLoading && total === 0 && (!poll.anonymous || receiptsLoaded)") {{ t('common.no_results_found') }}
  v-pagination(v-if="totalPages > 1" v-model="page" :length="totalPages")
</template>

<style scoped>
.poll-common-votes-panel__filter {
  max-width: 240px;
}

.poll-common-votes-panel__search {
  max-width: 280px;
}
</style>
