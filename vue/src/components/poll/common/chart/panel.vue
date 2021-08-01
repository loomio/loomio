<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import PollCommonDirective from '@/components/poll/common/directive'
import PollService from '@/shared/services/poll_service'
import { pick } from 'lodash'

import PollCommonChartBar from '@/components/poll/common/chart/bar'
import PollCommonChartCount from '@/components/poll/common/chart/count'
import PollCommonChartGrid from '@/components/poll/common/chart/grid'
import PollCommonChartPie from '@/components/poll/common/chart/pie'
import PollCommonChartRankedChoice from '@/components/poll/common/chart/ranked_choice'

export default
  components:
    {PollCommonChartBar,
     PollCommonChartCount,
     PollCommonChartGrid,
     PollCommonChartPie,
     PollCommonChartRankedChoice}

  props:
    poll: Object

  computed:
    type: ->
      switch @poll.pollType
        when 'proposal' then 'pie'
        when 'poll' then 'bar'
        when 'count' then 'count'
        when 'score' then 'bar'
        when 'dot_vote' then 'bar'
        when 'ranked_choice' then 'ranked_choice'
        when 'meeting' then 'grid'

</script>

<template lang="pug">
.poll-common-chart-panel
  poll-common-chart-bar(v-if="type == 'bar'" :poll="poll")
  poll-common-chart-count(v-if="type == 'count'" :poll="poll")
  poll-common-chart-pie(v-if="type == 'pie'" :poll="poll")
  poll-common-chart-grid(v-if="type == 'grid'" :poll="poll")
  poll-common-chart-ranked-choice(v-if="type == 'ranked_choice'" :poll="poll")
</template>

<style lang="sass">
</style>
