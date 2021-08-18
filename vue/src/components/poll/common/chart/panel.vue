<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import PollCommonDirective from '@/components/poll/common/directive'
import PollService from '@/shared/services/poll_service'
import { pick } from 'lodash'

import PollCommonChartPoll from '@/components/poll/common/chart/poll'
import PollCommonChartCount from '@/components/poll/common/chart/count'
import PollCommonChartMeeting from '@/components/poll/common/chart/meeting'
import PollCommonChartProposal from '@/components/poll/common/chart/proposal'
import PollCommonChartRankedChoice from '@/components/poll/common/chart/ranked_choice'

export default
  components:
    {PollCommonChartPoll,
     PollCommonChartCount,
     PollCommonChartMeeting,
     PollCommonChartProposal,
     PollCommonChartRankedChoice}

  props:
    poll: Object

  data: ->
    votersByOptionId: {}
    options: {}

  created: ->
    @watchRecords
      collections: ['pollOptions']
      query: =>
        if Session.isSignedIn()
          Records.users.fetchAnyMissingById(@poll.decidedVoterIds())
        @options = @poll.pollOptionsForResults()

  computed:
    pollType: -> @poll.pollType
</script>

<template lang="pug">
.poll-common-chart-panel
  v-subheader.ml-n4(v-t="'poll_common.results'")
  poll-common-chart-poll(v-if="['poll', 'score', 'dot_vote', 'ranked_choice'].includes(pollType)"
    :poll="poll" :options="options" :votersByOptionId="votersByOptionId")
  poll-common-chart-count(v-if="pollType == 'count'"
    :poll="poll" :options="options" :votersByOptionId="votersByOptionId")
  poll-common-chart-proposal(v-if="pollType == 'proposal'"
    :poll="poll" :options="options" :votersByOptionId="votersByOptionId")
  poll-common-chart-meeting(v-if="pollType == 'meeting'"
    :poll="poll" :options="options" :votersByOptionId="votersByOptionId")
  //- poll-common-chart-ranked-choice(v-if="pollType == 'ranked_choice'"
  //-   :poll="poll" :options="options" :votersByOptionId="votersByOptionId")
  poll-common-percent-voted(:poll="poll")
</template>

<style lang="sass">
</style>
