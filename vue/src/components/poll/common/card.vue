<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import PollCommonDirective from '@/components/poll/common/directive'
import PollTemplateBanner from '@/components/poll/template_banner'
import PollService from '@/shared/services/poll_service'
import { pickBy } from 'lodash'

export default
  components: { PollCommonDirective, PollTemplateBanner}

  props:
    poll: Object
    isPage: Boolean

  created: ->
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances", "outcomes"]
      query: (records) =>
        @actions = PollService.actions(@poll)
        @myStance = @poll.myStance() || Records.stances.build()
        @outcome = @poll.outcome()

  data: ->
    actions: {}
    buttonPressed: false
    myStance: null
    outcome: @poll.outcome()

  methods:
    titleVisible: (visible) ->
      EventBus.$emit('content-title-visible', visible) if @isPage

  computed:
    menuActions: ->
      pickBy @actions, (v) -> v.menu

    dockActions: ->
      pickBy @actions, (v) -> v.dock


</script>

<template lang="pug">
v-sheet
  poll-common-card-header(:poll='poll')
  div(v-if="poll.discardedAt")
    v-card-text
      .text--secondary(v-t="'poll_common_card.deleted'")
  div.px-2.pb-4.px-sm-4(v-else)
    poll-template-banner(:poll="poll")
    h1.poll-common-card__title.text-h4.py-2(tabindex="-1" v-observe-visibility="{callback: titleVisible}")
      poll-common-type-icon.mr-2(:poll="poll")
      span(v-if='!poll.translation.title') {{poll.title}}
      translation(:model='poll' field='title' v-if="poll.translation.title")
      tags-display(:tags="poll.tags()")
    poll-common-set-outcome-panel(:poll='poll' v-if="!outcome")
    poll-common-outcome-panel(:outcome='outcome' v-if="outcome")
    poll-common-details-panel(:poll='poll')
    poll-common-chart-panel(:poll='poll')
    poll-common-action-panel(:poll='poll')
    action-dock.mt-4(
      :menu-actions="menuActions"
      :actions="dockActions")
    .poll-common-card__results-shown.mt-4
      poll-common-votes-panel(:poll='poll')
</template>
<style lang="sass">
.v-card__title .poll-common-card__title
  word-break: normal
</style>
