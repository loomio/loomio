<script lang="js">
import Session  from '@/shared/services/session';
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import PollCommonDirective from '@/components/poll/common/directive';
import PollService from '@/shared/services/poll_service';
import PollCommonChartMeeting from '@/components/poll/common/chart/meeting';
import PollCommonChartTable from '@/components/poll/common/chart/table';
import PollCommonPercentVoted from '@/components/poll/common/percent_voted';
import PollCommonTargetProgress from '@/components/poll/common/target_progress';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  components: {
    PollCommonChartTable,
    PollCommonChartMeeting,
    PollCommonPercentVoted,
    PollCommonTargetProgress
  },

  props: {
    poll: Object
  },

  data() {
    return {votersByOptionId: {}};
  },

  created() {
    if (Session.isSignedIn()) {
      Records.fetch({path: "polls/"+this.poll.id+"/voters"})
    }
  }
};

</script>

<template lang="pug">
.poll-common-chart-panel.mt-8
  template(v-if="!poll.showResults()")
    v-alert.poll-common-action-panel__results-hidden-until-closed.my-2(
      v-if='!!poll.closingAt && poll.hideResults == "until_closed"'
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
    template(v-if="poll.config().has_options")
      poll-common-chart-table(v-if="poll.chartType != 'grid'" :poll="poll")
      poll-common-chart-meeting(v-else :poll="poll")
  poll-common-percent-voted.text-body-2.pl-2(v-if="poll.pollType != 'count'" :poll="poll")
</template>
