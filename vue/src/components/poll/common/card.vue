<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import PollCommonDirective from '@/components/poll/common/directive'
import PollService from '@/shared/services/poll_service'
import { pick } from 'lodash'

export default
  components:
    PollCommonDirective: PollCommonDirective

  props:
    poll: Object
    isPage: Boolean

  created: ->
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances", "outcomes"]
      query: (records) =>
        @myStance = @poll.myStance() || Records.stances.build()
        @outcome = @poll.outcome()

  data: ->
    buttonPressed: false
    myStance: null
    outcome: @poll.outcome()

  methods:
    titleVisible: (visible) ->
      EventBus.$emit('content-title-visible', visible) if @isPage

  computed:
    showResults: -> @poll.showResults()

    menuActions: ->
      @myStance
      pick PollService.actions(@poll, @), ['edit_poll', 'close_poll', 'reopen_poll', 'notification_history', 'show_history', 'move_poll', 'export_poll', 'print_poll', 'discard_poll', 'add_poll_to_thread', 'translate_poll']

    dockActions: ->
      @myStance
      pick PollService.actions(@poll, @), ['show_results', 'hide_results', 'edit_stance', 'announce_poll']

</script>

<template lang="pug">
v-card
  poll-common-card-header(:poll='poll')
  div(v-if="poll.discardedAt")
    v-card-text
      .text--secondary(v-t="'poll_common_card.deleted'")
  div(v-else)
    v-card-title
      h1.poll-common-card__title.display-1(tabindex="-1" v-observe-visibility="{callback: titleVisible}")
        span(v-if='!poll.translation.title') {{poll.title}}
        translation(v-if="poll.translation.title" :model='poll', field='title')
        v-chip.ml-3(outlined small color="info" v-t="'poll_types.' + poll.pollType")
    .px-4.pb-4
      poll-common-set-outcome-panel(:poll='poll' v-if="!outcome")
      poll-common-outcome-panel(:outcome='outcome' v-if="outcome")
      poll-common-details-panel(:poll='poll')
      .poll-common-card__results-shown(v-if='showResults')
        poll-common-directive(:poll='poll', name='chart-panel')
        poll-common-percent-voted(:poll='poll')
      poll-common-action-panel(:poll='poll')
      action-dock(:actions="dockActions" :menu-actions="menuActions")

      .poll-common-card__results-shown.mt-4(v-if='showResults')
        poll-common-votes-panel(:poll='poll')
</template>
<style lang="sass">
.v-card__title .poll-common-card__title
  word-break: normal
</style>
