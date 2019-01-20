<style lang="scss">
.thread-item--indent {
  margin-left: 42px;
}
.event-children__un-indent {
  margin-left: -42px;
}
</style>

<script lang="coffee">
AppConfig         = require 'shared/services/app_config'
EventBus          = require 'shared/services/event_bus'
NestedEventWindow = require 'shared/services/nested_event_window'

module.exports =
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

<template>
    <div class="event-children">

      <div v-if="debug()">event-childrenparentId: {{eventWindow.parentEvent.id}}cc: {{eventWindow.parentEvent.childCount}}min: {{eventWindow.min}}max: {{eventWindow.max}}first: {{eventWindow.firstLoaded()}}last: {{eventWindow.lastLoaded()}}anyPrevious: {{eventWindow.anyPrevious()}}anyNext: {{eventWindow.anyNext()}}</div>

      <a
        v-show="eventWindow.anyPrevious() && !eventWindow.loader.loadingPrevious"
        @click="eventWindow.showPrevious()"
        class="activity-card__load-more lmo-no-print thread-item--indent-margin"
      >
        <i class="mdi mdi-autorenew"></i>
        <span v-t="{ path: 'activity_card.n_previous', args: { count: eventWindow.numPrevious() } }"></span>
      </a>
      <loading v-show="eventWindow.loader.loadingPrevious" class="activity-card__loading page-loading"></loading>
      <thread-item v-for="event in eventWindow.windowedEvents()" :key="event.id" :event-window="eventWindow" :event="event"></thread-item>
      <a
        v-show="eventWindow.anyNext() && !eventWindow.loader.loadingMore"
        @click="eventWindow.showNext()"
        class="activity-card__load-more lmo-no-print thread-item--indent-margin"
      >
        <i class="mdi mdi-autorenew"></i>
        <span v-t="{ path: 'activity_card.n_more', args: { count: eventWindow.numNext() } }"></span>
      </a>
      <loading v-show="eventWindow.loader.loadingMore" class="activity-card__loading page-loading"></loading>
    </div>
</template>
