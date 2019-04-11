<style lang="scss">
.thread-item--indent {
  margin-left: 42px;
}
.event-children__un-indent {
  margin-left: -42px;
}
</style>

<script lang="coffee">
import AppConfig         from '@/shared/services/app_config'
import EventBus          from '@/shared/services/event_bus'
import NestedEventWindow from '@/shared/services/nested_event_window'

export default
  props:
    parentEvent: Object
    parentEventWindow: Object
  data: ->
    eventWindow: new NestedEventWindow
      parentEvent:       @parentEvent
      discussion:        @parentEventWindow.discussion
      initialSequenceId: @parentEventWindow.initialSequenceId
      per:               @parentEventWindow.per
  # mounted: ->
  #   EventBus.listen @, 'replyToEvent', (e, event, comment) ->
  #     if event.id == @parentEvent.id
  #       @eventWindow.max = false
  methods:
    debug: -> AppConfig.debug
</script>

<template lang="pug">
.event-children
  div(v-if='debug()')
    | event-childrenparentId: {{eventWindow.parentEvent.id}}cc: {{eventWindow.parentEvent.childCount}}min: {{eventWindow.min}}max: {{eventWindow.max}}first: {{eventWindow.firstLoaded()}}last: {{eventWindow.lastLoaded()}}anyPrevious: {{eventWindow.anyPrevious()}}anyNext: {{eventWindow.anyNext()}}
  a.activity-card__load-more.lmo-no-print.thread-item--indent-margin(v-show='eventWindow.anyPrevious() && !eventWindow.loader.loadingPrevious', @click='eventWindow.showPrevious()')
    i.mdi.mdi-autorenew
    span(v-t="{ path: 'activity_card.n_previous', args: { count: eventWindow.numPrevious() } }")
  loading.activity-card__loading.page-loading(v-show='eventWindow.loader.loadingPrevious')
  thread-item(v-for='event in eventWindow.windowedEvents()', :key='event.id', :event-window='eventWindow', :event='event')
  a.activity-card__load-more.lmo-no-print.thread-item--indent-margin(v-show='eventWindow.anyNext() && !eventWindow.loader.loadingMore', @click='eventWindow.showNext()')
    i.mdi.mdi-autorenew
    span(v-t="{ path: 'activity_card.n_more', args: { count: eventWindow.numNext() } }")
  loading.activity-card__loading.page-loading(v-show='eventWindow.loader.loadingMore')
</template>
