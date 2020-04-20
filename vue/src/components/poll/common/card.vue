<script lang="coffee">
import Session  from '@/shared/services/session'
import Records  from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import { myLastStanceFor, iconFor }  from '@/shared/helpers/poll'
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
    EventBus.$on 'showResults', => @buttonPressed = true
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances", "outcomes"]
      query: (records) =>
        @myLastStance = myLastStanceFor(@poll)?
        @outcome = @poll.outcome()

  data: ->
    buttonPressed: false
    myLastStance: null
    outcome: null

  methods:
    titleVisible: (visible) ->
      EventBus.$emit('content-title-visible', visible) if @isPage

  computed:
    icon: -> iconFor(@poll)
    showResults: ->
      @buttonPressed || @myLastStance || @poll.isClosed()

    menuActions: ->
      @myLastStance
      pick PollService.actions(@poll, @), ['edit_poll', 'close_poll', 'reopen_poll', 'export_poll', 'delete_poll', 'translate_poll']

    dockActions: ->
      @myLastStance
      pick PollService.actions(@poll, @), ['announce_poll', 'edit_stance']

</script>

<template lang="pug">
v-card
  poll-common-card-header(:poll='poll')
  v-card-title
    h1.poll-common-card__title.display-1(v-observe-visibility="{callback: titleVisible}")
      span(v-if='!poll.translation.title') {{poll.title}}
      translation(v-if="poll.translation.title" :model='poll', field='title')
      v-chip.ml-3(outlined small color="info" v-t="'poll_types.' + poll.pollType")
  v-card-text
    poll-common-set-outcome-panel(:poll='poll')
    poll-common-outcome-panel(:poll='poll', v-if='outcome')
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
