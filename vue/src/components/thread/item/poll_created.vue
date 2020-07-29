<script lang="coffee">
import PollService    from '@/shared/services/poll_service'
import AbilityService from '@/shared/services/ability_service'
import EventBus       from '@/shared/services/event_bus'
import EventService from '@/shared/services/event_service'
import { pick, assign } from 'lodash-es'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    event: Object
    isReturning: Boolean

  created: ->
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances"]
      query: (records) =>
        @myStance = @poll.myStance()

  beforeDestroy: ->
    EventBus.$off 'showResults'
    EventBus.$off 'stanceSaved'

  data: ->
    buttonPressed: false
    myStance: null

  computed:
    eventable: -> @event.model()
    poll: -> @eventable

    showResults: ->
      @poll.showResults()

    menuActions: ->
      assign(
        pick PollService.actions(@poll, @), ['show_history', 'export_poll', 'print_poll', 'discard_poll', 'add_poll_to_thread', 'translate_poll']
      ,
        pick EventService.actions(@event, @), ['move_event', 'copy_url', 'pin_event', 'unpin_event']
      )
    dockActions: ->
      pick PollService.actions(@poll, @), ['show_results', 'hide_results', 'edit_stance', 'announce_poll', 'edit_poll', 'close_poll', 'reopen_poll']

</script>

<template lang="pug">
thread-item.poll-created(:event="event" :is-returning="isReturning")
  v-layout(justify-space-between)
    h1.poll-common-card__title.headline(tabindex="-1")
      router-link(:to="urlFor(poll)" v-if='!poll.translation.title') {{poll.title}}
      translation(v-if="poll.translation.title" :model='poll', field='title')
      poll-common-closing-at.ml-2(:poll='poll')
  poll-common-set-outcome-panel(:poll='poll')
  poll-common-outcome-panel(:poll='poll', v-if='poll.outcome()')
  formatted-text.poll-common-details-panel__details(:model="poll" column="details")
  attachment-list(:attachments="poll.attachments")
  document-list(:model='poll' skip-fetch)
  p.caption(v-if="!poll.pollOptionNames.length" v-t="'poll_common.no_voting'")
  div.body-2(v-if="poll.pollOptionNames.length")
    .poll-common-card__results-shown(v-if='poll.showResults()')
      poll-common-directive(:poll='poll', name='chart-panel')
      poll-common-percent-voted(:poll='poll')
    poll-common-action-panel(:poll='poll')
  template(v-slot:actions)
    action-dock.my-2(:actions="dockActions" :menu-actions="menuActions")
  template(v-if="!poll.stancesInDiscussion && poll.showResults()" v-slot:afterActions)
    poll-common-votes-panel(v-if :poll="poll")
</template>
