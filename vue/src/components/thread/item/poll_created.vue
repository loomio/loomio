<script lang="coffee">
import PollService    from '@/shared/services/poll_service'
import AbilityService from '@/shared/services/ability_service'
import PollModalMixin from '@/mixins/poll_modal'
import EventBus       from '@/shared/services/event_bus'
import EventService from '@/shared/services/event_service'
import { myLastStanceFor }  from '@/shared/helpers/poll'
import { pick, assign } from 'lodash'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  mixins: [PollModalMixin]
  props:
    event: Object

  created: ->
    EventBus.$on 'showResults', => @buttonPressed = true
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances"]
      query: (records) =>
        @myLastStance = myLastStanceFor(@poll)?

  beforeDestroy: ->
    EventBus.$off 'showResults'
    EventBus.$off 'stanceSaved'

  data: ->
    buttonPressed: false
    myLastStance: null

  computed:
    eventable: -> @event.model()
    poll: -> @eventable

    showResults: ->
      @buttonPressed || @myLastStance || @poll.isClosed()

    menuActions: ->
      assign(
        pick PollService.actions(@poll, @), ['show_history', 'export_poll', 'delete_poll', 'translate_poll']
      ,
        pick EventService.actions(@event, @), ['move_event', 'pin_event', 'unpin_event']
      )
    dockActions: ->
      pick PollService.actions(@poll, @), ['announce_poll', 'edit_poll', 'close_poll', 'reopen_poll']

</script>

<template lang="pug">
thread-item.poll-created(:event="event")
  v-layout(justify-space-between)
    h1.poll-common-card__title.headline
      span(v-if='!poll.translation.title') {{poll.title}}
      translation(v-if="poll.translation.title" :model='poll', field='title')
      poll-common-closing-at.ml-2(:poll='poll')
  poll-common-set-outcome-panel(:poll='poll')
  poll-common-outcome-panel(:poll='poll', v-if='poll.outcome()')
  formatted-text.poll-common-details-panel__details(:model="poll" column="details")
  attachment-list(:attachments="poll.attachments")
  document-list(:model='poll' skip-fetch)
  p.caption(v-if="!poll.pollOptionNames.length" v-t="'poll_common.no_voting'")
  div.body-2(v-if="poll.pollOptionNames.length")
    .poll-common-card__results-shown(v-if='showResults')
      poll-common-directive(:poll='poll', name='chart-panel')
      poll-common-percent-voted(:poll='poll')
    poll-common-action-panel(:poll='poll')
  template(v-slot:actions)
    action-dock(:actions="dockActions" :menu-actions="menuActions")
</template>
