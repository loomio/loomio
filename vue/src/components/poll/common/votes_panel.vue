<script setup lang="js">
import Records from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import { debounce } from 'lodash-es';
import { computed, onMounted, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useRoute, useRouter } from 'vue-router';

const { poll } = defineProps({ poll: Object });
const { t } = useI18n();
const route = useRoute();
const router = useRouter();
const limit = 25;
const page = ref(Math.max(1, parseInt(route.query.page, 10) || 1));
const name = ref(route.query.name || '');
const voteFilter = ref(route.query.poll_option_id ? Number(route.query.poll_option_id) : (route.query.stance_filter || 'all'));
const voters = ref([]);
const meta = ref(null);
const loading = ref(false);
let fetchSequence = 0;
const canView = !poll.anonymous || AbilityService.canVerifyParticipants(poll);
const totalPages = computed(() => Math.max(1, Math.ceil((meta.value?.total || 0) / limit)));
const rangeFirst = computed(() => meta.value?.total ? (page.value - 1) * limit + 1 : 0);
const rangeLast = computed(() => Math.min(page.value * limit, meta.value?.total || 0));

const pollOptionItems = computed(() => {
  const items = [
    { title: t('poll_common_votes_panel.all_voters'), value: 'all' },
    { title: t('poll_common_votes_panel.cast'), value: 'cast' },
    { title: t('poll_common_votes_panel.uncast'), value: 'uncast' }
  ];
  return poll.showResults() ? items.concat(poll.pollOptions().map(option => ({ title: option.optionName(), value: option.id }))) : items;
});

function shownChoices(voter) {
  const choices = Object.entries(voter.option_scores || {}).map(([id, score]) => ({
    option: poll.pollOptions().find(option => option.id === Number(id)),
    score,
    rank: poll.pollType === 'ranked_choice' ? poll.minimumStanceChoices - score + 1 : null
  })).filter(choice => choice.option && (choice.score > 0 || poll.pollType === 'score'));
  return poll.pollType === 'ranked_choice'
    ? choices.sort((a, b) => a.rank - b.rank)
    : choices.sort((a, b) => b.score - a.score);
}

function voteLabel(voter) {
  if (!voter.vote_cast) { return t('poll_receipts_page.not_voted'); }
  if (!poll.showResults() || !poll.config().has_options) { return t('poll_receipts_page.voted'); }
  const choices = shownChoices(voter);
  if (!choices.length) { return t('poll_common_form.none_of_the_above'); }
  return choices.map(choice => {
    const name = choice.rank ? `${choice.rank}. ${choice.option.optionName()}` : choice.option.optionName();
    // Meeting scores are 2 for yes and 1 for "if need be", not point values.
    if (poll.pollType === 'meeting') { return choice.score === 1 ? `${name} (${t('poll_meeting_vote_form.if_need_be')})` : name; }
    return poll.hasVariableScore() && poll.pollType !== 'ranked_choice' ? `${name} (${choice.score})` : name;
  }).join(', ');
}

async function fetchVotes() {
  const sequence = ++fetchSequence;
  const params = { limit, offset: (page.value - 1) * limit };
  if (name.value) { params.name = name.value; }
  if (!poll.anonymous) {
    if (typeof voteFilter.value === 'number') { params.poll_option_id = voteFilter.value; }
    if (voteFilter.value === 'cast' || voteFilter.value === 'uncast') { params.stance_filter = voteFilter.value; }
  }
  loading.value = true;
  try {
    const data = await Records.fetch({ path: `polls/${poll.id}/votes`, params });
    if (sequence !== fetchSequence) { return; }
    if (page.value > Math.max(1, Math.ceil(data.meta.total / limit))) {
      page.value = Math.max(1, Math.ceil(data.meta.total / limit));
      return;
    }
    voters.value = data.voters;
    meta.value = data.meta;
  } catch (error) {
    if (sequence === fetchSequence) { EventBus.$emit('pageError', error); }
  } finally {
    if (sequence === fetchSequence) { loading.value = false; }
  }
}

const fetchDebounced = debounce(fetchVotes, 100);
onMounted(() => { if (canView) { fetchVotes(); } });

// Build the whole query from current state. Both watchers can run in one flush
// before the router updates route.query, so neither may copy our keys from it.
function replaceQuery() {
  router.replace({ query: {
    ...route.query,
    page: page.value === 1 ? undefined : page.value,
    name: name.value || undefined,
    stance_filter: !poll.anonymous && typeof voteFilter.value === 'string' && voteFilter.value !== 'all' ? voteFilter.value : undefined,
    poll_option_id: !poll.anonymous && typeof voteFilter.value === 'number' ? voteFilter.value : undefined
  } });
}

watch(page, () => {
  replaceQuery();
  if (canView) { fetchVotes(); }
});

watch([name, voteFilter], () => {
  if (page.value !== 1) {
    page.value = 1;
    return;
  }
  replaceQuery();
  if (canView) { fetchDebounced(); }
});
</script>

<template lang="pug">
.poll-common-votes-panel#votes
  p.text-medium-emphasis.my-4(v-if="!canView") {{ t('poll_common_votes_panel.participation_records_restricted') }}
  .votes-content(v-else="")
    p.text-medium-emphasis.my-3(v-if="poll.anonymous && meta?.participation_status_visible") {{ t('poll_receipts_page.participation_records_explanation') }}
    p.text-medium-emphasis.my-3(v-else-if="poll.anonymous && meta") {{ t('poll_receipts_page.participation_status_requires_min_votes', { count: meta.participation_status_votes_min }) }}
    p.text-medium-emphasis.my-3(v-if="meta?.show_voter_email") {{ t('poll_receipts_page.email_addresses_only_for_group_admins') }}
    .d-flex.flex-wrap.ga-2.my-3
      v-select.poll-common-votes-panel__filter(v-if="!poll.anonymous" :items="pollOptionItems" :label="t('common.option')" v-model="voteFilter" density="compact" hide-details)
      v-text-field.poll-common-votes-panel__search(v-model="name" :label="t('poll_common_votes_panel.name_or_username')" density="compact" hide-details clearable)
    .poll-common-votes-panel__table-wrap(v-if="meta")
      v-table(density="compact")
        thead
          tr
            th
            th {{ t('poll_receipts_page.voter_name') }}
            th(v-if="meta?.show_voter_email") {{ t('poll_receipts_page.voter_email') }}
            th(v-if="!poll.anonymous || meta?.participation_status_visible") {{ t(poll.anonymous ? 'poll_receipts_page.vote_cast' : 'poll_common_votes_panel.stance') }}
            th(v-if="poll.voteWeightsEnabled") {{ t('poll_common_votes_panel.vote_weight_column') }}
            th(v-if="meta?.show_voter_details") {{ t('poll_receipts_page.member_since') }}
            th(v-if="meta?.show_voter_details") {{ t('poll_receipts_page.invited_by') }}
            th(v-if="meta?.show_voter_details") {{ t('poll_receipts_page.invited_on') }}
        tbody
          tr(v-for="voter in voters" :key="voter.voter_id")
            td
              v-avatar(:image="voter.voter_thumb_url" :size="24")
                span(v-if="!voter.voter_thumb_url") {{ voter.voter_avatar_initials }}
            td {{ voter.voter_name }}
            td(v-if="meta?.show_voter_email") {{ voter.voter_email }}
            td(v-if="poll.anonymous && meta?.participation_status_visible")
              v-icon(:icon="voter.vote_cast ? 'mdi-check' : 'mdi-close'" :color="voter.vote_cast ? 'success' : 'error'" size="small" :aria-label="t(voter.vote_cast ? 'poll_receipts_page.voted' : 'poll_receipts_page.not_voted')")
            td(v-if="!poll.anonymous") {{ voteLabel(voter) }}
            td(v-if="poll.voteWeightsEnabled") {{ voter.weight }}
            td(v-if="meta?.show_voter_details") {{ voter.member_since }}
            td(v-if="meta?.show_voter_details") {{ voter.inviter_name }}
            td(v-if="meta?.show_voter_details") {{ voter.invited_on }}
    progress.poll-common-votes-panel__loading(v-if="loading" :aria-label="t('common.action.loading')")
    p.text-medium-emphasis.my-4(v-if="!loading && meta && meta.total === 0") {{ t('common.no_results_found') }}
    .d-flex.align-center.justify-space-between.flex-wrap.ga-2.mt-4(v-if="meta && meta.total > 0")
      span.text-medium-emphasis {{ t('poll_common_form.voter_page_count', { first: rangeFirst, last: rangeLast, total: meta.total }) }}
      v-pagination.poll-common-votes-panel__pagination(v-if="totalPages > 1" v-model="page" :length="totalPages")
</template>

<style scoped>
.poll-common-votes-panel__filter { max-width: 240px; }
.poll-common-votes-panel__search { max-width: 280px; }
.poll-common-votes-panel__table-wrap { overflow-x: auto; }
.poll-common-votes-panel__loading { width: 100%; }
.poll-common-votes-panel__pagination { width: auto; margin-left: auto; }
</style>
