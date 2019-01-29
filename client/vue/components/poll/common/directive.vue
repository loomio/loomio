<style lang="scss">
</style>

<script lang="coffee">
import PollProposalForm from 'vue/components/poll/proposal/form.vue'
import PollCommonVoteForm from 'vue/components/poll/common/vote_form.vue'
import PollPollForm from 'vue/components/poll/poll/form.vue'
import PollCountForm from 'vue/components/poll/count/form.vue'
import PollDotVoteForm from 'vue/components/poll/dot_vote/form.vue'
import PollScoreForm from 'vue/components/poll/score/form.vue'
import PollMeetingForm from 'vue/components/poll/meeting/form.vue'
import PollRankedChoiceForm from 'vue/components/poll/ranked_choice/form.vue'
import PollCommonChangeYourVote from 'vue/components/poll/common/change_your_vote.vue'
import PollProposalChartPanel from 'vue/components/poll/proposal/chart_panel.vue'
import PollCommonVotesPanelStance from 'vue/components/poll/common/votes_panel_stance.vue'
import PollProposalStanceChoice from 'vue/components/poll/proposal/stance_choice.vue'
import PollCountStanceChoice from 'vue/components/poll/count/stance_choice.vue'
import PollCountChartPanel from 'vue/components/poll/count/chart_panel.vue'
import PollPollVoteForm from 'vue/components/poll/poll/vote_form.vue'
import PollDotVoteVoteForm from 'vue/components/poll/dot_vote/vote_form.vue'
import PollDotVoteStanceChoice from 'vue/components/poll/dot_vote/stance_choice.vue'
import PollPollStanceChoice from 'vue/components/poll/poll/stance_choice.vue'
import PollPollChartPanel from 'vue/components/poll/poll/chart_panel.vue'
import PollCommonBarChartPanel from 'vue/components/poll/common/bar_chart_panel.vue'
import PollDotVoteChartPanel from 'vue/components/poll/dot_vote/chart_panel.vue'
module.exports =
  components:
    'poll-proposal-form': PollProposalForm
    'poll-common-vote-form': PollCommonVoteForm
    'poll-poll-form': PollPollForm
    'poll-count-form': PollCountForm
    'poll-dot_vote-form': PollDotVoteForm
    'poll-score-form': PollScoreForm
    'poll-meeting-form': PollMeetingForm
    'poll-ranked_choice-form': PollRankedChoiceForm
    'poll-common-change-your-vote': PollCommonChangeYourVote
    'poll-proposal-chart-panel': PollProposalChartPanel
    'poll-common-votes-panel-stance': PollCommonVotesPanelStance
    'poll-proposal-stance-choice': PollProposalStanceChoice
    'poll-count-stance-choice': PollCountStanceChoice
    'poll-count-chart-panel': PollCountChartPanel
    'poll-poll-vote-form': PollPollVoteForm
    'poll-dot_vote-vote-form': PollDotVoteVoteForm
    'poll-dot_vote-stance-choice': PollDotVoteStanceChoice
    'poll-poll-stance-choice': PollPollStanceChoice
    'poll-poll-chart-panel': PollPollChartPanel
    'poll-common-bar-chart-panel': PollCommonBarChartPanel
    'poll-dot_vote-chart-panel': PollDotVoteChartPanel
  props:
    poll: Object
    stance: Object
    outcome: Object
    stanceChoice: Object
    back: Object
    name: String
  methods:
    componentName: ->
      pollType = (@stance or @outcome or @stanceChoice or @poll).poll().pollType

      console.log('pollType', pollType)
      console.log("poll-#{pollType}-#{@name}")

      if @$options.components["poll-#{pollType}-#{@name}"]
        "poll-#{pollType}-#{@name}"
      else
        "poll-common-#{@name}"
</script>

<template>
  <component :is="componentName()" :poll='poll' :stance='stance' :stance-choice='stanceChoice' :outcome='outcome' :back='back'></component>
</template>
