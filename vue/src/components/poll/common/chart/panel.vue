<script lang="js">
import Session  from '@/shared/services/session';
import Records  from '@/shared/services/records';
import PollCommonChartMeeting from '@/components/poll/common/chart/meeting';
import PollCommonChartTable from '@/components/poll/common/chart/table';
import PollStvChartPanel from '@/components/poll/stv/chart_panel';

export default {
  components: {
    PollCommonChartTable,
    PollCommonChartMeeting,
    PollStvChartPanel,
  },

  props: {
    poll: Object,
    hideVoters: Boolean
  },

  data() {
    return { votersByOptionId: {} };
  },

  created() {
    if (Session.isSignedIn() && (!this.hideVoters || this.poll.chartType == 'grid')) {
      Records.fetch({path: "polls/"+this.poll.id+"/voters"})
    }
  }
};

</script>

<template lang="pug">
.poll-common-chart-panel.mt-8
  template(v-if="!poll.showResults()")
    v-alert.poll-common-action-panel__results-hidden-until-closed.my-2(
      v-if='!!poll.closingAt && poll.hideResults == "until_closed" && !poll.detachedAnonymousVoting()'
      density="compact"
      variant="tonal"
      type="info"
    )
      span(v-t="{path: 'poll_common_action_panel.results_hidden_until_closed', args: {poll_type: poll.pollType}}" )
    v-alert.poll-common-action-panel__results-hidden-until-vote.my-2(
      v-if='!!poll.closingAt && !poll.iHaveVoted() && poll.hideResults == "until_vote"'
      density="compact"
      variant="tonal"
      type="info"
    )
      span(v-t="'poll_common_action_panel.results_hidden_until_vote'")
  template(v-else)
    v-alert.mb-4(v-if="poll.quorumPct || poll.results.some(r => r.test_operator)" color="info" variant="tonal")
      p(v-if="poll.pollType == 'proposal'" v-t="'poll_common_action_panel.for_this_proposal_to_pass'")
      p(v-else v-t="{path: 'poll_common_action_panel.for_this_poll_type_to_be_valid', args: {poll_type: poll.translatedPollType()}}")
      ul(style="list-style-type: none; padding-left: 0;")
        li.text-medium-emphasis.d-flex.align-center(v-if="poll.quorumPct")
          common-icon.mr-1(
            :name="poll.quorumVotesRequired <= 0 ? 'mdiCheckboxMarkedOutline' : 'mdiCheckboxBlankOutline'"
            :color="poll.quorumVotesRequired <= 0 ? 'success' : (poll.isClosed() ? 'error' : undefined)"
          )
          span(v-t="{path: 'poll_common_percent_voted.pct_of_eligible_voters_must_participate', args: {pct: poll.quorumPct}}")
        li.text-medium-emphasis.d-flex.align-center(v-for="option in poll.results.filter(option => option.test_operator)")
          common-icon.mr-1(
            :name="option.test_result ? 'mdiCheckboxMarkedOutline' : 'mdiCheckboxBlankOutline'"
            :color="option.test_result ? 'success' : (poll.isClosed() ? 'error' : undefined)"
          )
          span(v-t="{path: `poll_option_form.name_${option.test_operator}_${option.test_against}`, args: {percent: option.test_percent, name: option.name} }")
    template(v-if="poll.config().has_options")
      poll-stv-chart-panel(v-if="poll.pollType == 'stv'" :poll="poll")
      template(v-else-if="poll.chartType != 'grid'")
        v-alert.poll-common-chart-panel__variable-vote-weights.mb-4(
          v-if="poll.weightedVoting"
          density="compact"
          variant="tonal"
          type="info"
        )
          span {{ $t('poll_common_action_panel.votes_have_different_weights') }}
          help-link.ml-1(path="user_manual/polls/weighted_voting")
        poll-common-chart-table(:poll="poll" :hide-voters="hideVoters")
      poll-common-chart-meeting(v-else :poll="poll")

  p.text-medium-emphasis.my-2(v-if="poll.closingAt && poll.pollType != 'count'")
    span( v-t="{ path: 'poll_common_percent_voted.pct_participation', args: { num: poll.decidedVotersCount, total: poll.votersCount, pct: poll.castStancesPct } }" )
</template>
