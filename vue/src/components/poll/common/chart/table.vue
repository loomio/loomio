<script lang="coffee">
import Records from '@/shared/services/records'
import { fieldFromTemplate, myLastStanceFor } from '@/shared/helpers/poll'
import { max, values, orderBy, compact } from 'lodash'
import BarIcon from '@/components/poll/common/icon/bar.vue'
import CountIcon from '@/components/poll/common/icon/count.vue'
import PieIcon from '@/components/poll/common/icon/pie.vue'
import GridIcon from '@/components/poll/common/icon/grid.vue'
import Vue from 'vue'

export default
  components: {BarIcon, CountIcon, PieIcon, GridIcon}
  props:
    poll: Object

  data: ->
    users: {}

  created: ->
    @watchRecords
      collections: ['users']
      query: =>
        @poll.results.forEach (option) =>
          option.voter_ids.forEach (id) =>
            Vue.set @users, id, Records.users.find(id)

</script>

<template lang="pug">
.poll-common-chart-table
  //- p {{poll.results}}
  v-simple-table(dense)
    thead
      tr
        template(v-for="col in poll.resultColumns")
          th.text-left(v-if="['pie', 'bar', 'grid'].includes(col)")
          th.text-left(v-if="col == 'name'" v-t='"common.option"')
          th.text-right(v-if="col == 'score_percent'" v-t='"poll_ranked_choice_form.pct_of_points"')
          th.text-right(v-if="col == 'voter_percent'" v-t='"poll_ranked_choice_form.pct_of_voters"')
          th.text-right(v-if="col == 'score'" v-t='"poll_ranked_choice_form.points"')
          th.text-right(v-if="col == 'rank'" v-t='"poll_ranked_choice_form.rank"')
          th.text-right(v-if="col == 'average'" v-t='"poll_ranked_choice_form.mean"')
          th.text-right(v-if="col == 'voter_count'" v-t='"membership_card.voters"')
          th(v-if="col == 'voters'")
    tbody
      tr(v-for="option, index in poll.results" :key="option.id")
        template(v-for="col in poll.resultColumns")
          td.pa-0(style="vertical-align: top" v-if="col == 'pie' && index == 0" :rowspan="poll.results.length")
            pie-icon.ma-2(:poll="poll" :size='128')
          td.pr-2.py-2(v-if="col == 'bar'" style="width: 128px; padding: 0 8px 0 0")
            div.rounded(:style="{width: option[poll.chartColumn]+'%', height: '24px', 'background-color': option.color}")
          td(v-if="col == 'name' && option.name_format == 'iso8601'")
            // poll-meeting-time(:name='option.name')
          td(v-if="col == 'name' && option.name_format == 'i18n' && poll.chartType == 'pie'" v-t="option.name" :style="{'border-left': '4px solid ' + option.color}")
          td(v-if="col == 'name' && option.name_format == 'i18n' && poll.chartType != 'pie'" v-t="option.name")
          td(v-if="col == 'name' && option.name_format == 'none'") {{option.name}} 
          td.text-right(v-if="col == 'rank'") {{option.rank}}
          td.text-right(v-if="col == 'score'") {{option.score}}
          td.text-right(v-if="col == 'voter_count'") {{option.voter_count}}
          td.text-right(v-if="col == 'average'") {{Math.round((option.average + Number.EPSILON) * 100) / 100}}
          td.text-right(v-if="col == 'voter_percent'") {{option.voter_percent.toFixed(0)}}%
          td.text-right(v-if="col == 'score_percent'") {{option.score_percent.toFixed(0)}}%
          td.text-right(v-if="col == 'voters'")
            div.poll-common-chart-table__voter-avatars
              user-avatar.float-left(v-for="id in option.voter_ids" :key="id" :user="users[id]" :size="24" no-link)
</template>
<style lang="sass">
.v-data-table > .v-data-table__wrapper > table > tbody > tr:hover:not(.v-data-table__expanded__content):not(.v-data-table__empty-wrapper)
  background: none !important
  
.poll-common-chart-table
  table
    width: 100%

.poll-common-chart-table__voter-avatars
  position: relative
  max-height: 72px
  overflow: hidden
  background: -webkit-linear-gradient(rgba(0,0,0,0), rgba(0,0,0,1))
  -webkit-background-clip: text
  -webkit-text-fill-color: transparent

.poll-common-chart-table__voter-avatars:hover
  max-height: none
  overflow: show

</style>
