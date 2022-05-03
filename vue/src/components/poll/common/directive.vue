<script lang="coffee">
import PollCommonVoteForm from '@/components/poll/common/vote_form.vue'
import PollCommonChangeYourVote from '@/components/poll/common/change_your_vote.vue'
import PollPollVoteForm from '@/components/poll/poll/vote_form.vue'
import PollDotVoteVoteForm from '@/components/poll/dot_vote/vote_form.vue'
import PollScoreVoteForm from '@/components/poll/score/vote_form.vue'
import PollCommonStanceChoice from '@/components/poll/common/stance_choice.vue'
import PollRankedChoiceVoteForm from '@/components/poll/ranked_choice/vote_form.vue'
import PollMeetingVoteForm from '@/components/poll/meeting/vote_form.vue'
import PollCommonVotesPanel from '@/components/poll/common/votes_panel.vue'

export default
  components:
    'poll-common-vote-form': PollCommonVoteForm
    'poll-common-change-your-vote': PollCommonChangeYourVote
    'poll-poll-vote-form': PollPollVoteForm
    'poll-dot_vote-vote-form': PollDotVoteVoteForm
    'poll-score-vote-form': PollScoreVoteForm
    'poll-common-stance-choice': PollCommonStanceChoice
    'poll-ranked_choice-vote-form': PollRankedChoiceVoteForm
    'poll-meeting-vote-form': PollMeetingVoteForm

  props:
    poll: Object
    stance: Object
    outcome: Object
    stanceChoice: Object
    back: Object
    name: String
    size: Number
    shouldReset: Boolean
  computed:
    componentName: ->
      pollType = (@stance or @outcome or @stanceChoice or @poll).poll().pollType

      if @$options.components["poll-#{pollType}-#{@name}"]
        "poll-#{pollType}-#{@name}"
      else
        # console.log 'no match, falling through to common ', "poll-common-#{@name}"
        "poll-common-#{@name}"
</script>

<template>
  <component :is="componentName" :poll='poll' :stance='stance' :stance-choice='stanceChoice' :outcome='outcome' :back='back' :size="size" :should-reset="shouldReset"></component>
</template>
