<script lang="coffee">
import Session        from '@/shared/services/session'
import PollService    from '@/shared/services/poll_service'
import AbilityService from '@/shared/services/ability_service'
import PollModalMixin from '@/mixins/poll_modal'
import EventBus       from '@/shared/services/event_bus'
import WatchRecords   from '@/mixins/watch_records'
import { myLastStanceFor }  from '@/shared/helpers/poll'
import { pick } from 'lodash'

import { listenForTranslations } from '@/shared/helpers/listen'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  mixins: [PollModalMixin, WatchRecords]
  props:
    eventWindow: Object
    event: Object

  created: ->
    EventBus.$on 'showResults', => @buttonPressed = true
    EventBus.$on 'stanceSaved', => EventBus.$emit 'refreshStance'
    @watchRecords
      collections: ["stances"]
      query: (records) =>
        @myLastStance = myLastStanceFor(@poll)?

  data: ->
    buttonPressed: false
    myLastStance: null

  computed:
    eventable: -> @event.model()
    poll: -> @eventable

    showResults: ->
      @buttonPressed || @myLastStance || @poll.isClosed()

    menuActions: ->
      pick PollService.actions(@poll, @), ['edit_poll', 'show_history', 'close_poll', 'reopen_poll', 'export_poll', 'delete_poll', 'translate_poll']
    dockActions: ->
      pick PollService.actions(@poll, @), ['announce_poll']

  mounted: ->
    listenForTranslations @
</script>

<template lang="pug">
thread-item.poll-created(:event="event" :event-window="eventWindow")
  template(v-slot:actions)
    action-dock(:actions="dockActions")
    action-menu(:actions="menuActions")
  v-layout(justify-space-between)
    h1.poll-common-card__title.headline
      span(v-if='!poll.translation') {{poll.title}}
      translation(v-if="poll.translation" :model='poll', :field='title')
  poll-common-closing-at(:poll='poll')
  poll-common-set-outcome-panel(:poll='poll')
  poll-common-outcome-panel(:poll='poll', v-if='poll.outcome()')
  formatted-text.poll-common-details-panel__details(:model="poll" column="details")
  attachment-list(:attachments="poll.attachments")
  .poll-common-card__results-shown(v-if='showResults')
    poll-common-directive(:poll='poll', name='chart-panel')
    poll-common-percent-voted(:poll='poll')
  poll-common-action-panel(:poll='poll')
  document-list(:model='poll' skip-fetch)
</template>
