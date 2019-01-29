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

      if @$options.components["poll-#{pollType}-#{@name}"]
        "poll-#{pollType}-#{@name}"
      else
        "poll-common-#{@name}"
</script>

<template>
  <component :is="componentName()" :poll='poll' :stance='stance' :stance-choice='stanceChoice' :outcome='outcome' :back='back'></component>
</template>
