<script lang="coffee">
import Records from '@/shared/services/records'
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import { max, values, orderBy, compact } from 'lodash'
import PollCommonChartTable from '@/components/poll/common/chart/table'
import PollCommonChartBar from '@/components/poll/common/chart/bar'

export default
  components: {PollCommonChartTable, PollCommonChartBar}
  props:
    poll: Object
    options: Array

</script>

<template lang="pug">
.poll-common-chart-poll
  poll-common-chart-bar.mb-2(:poll="poll" :options="options")
  poll-common-chart-table(:poll="poll" :options="options")
</template>
<style lang="sass">

</style>
