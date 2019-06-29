<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'

import { submitForm } from '@/shared/helpers/form'
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext'
import { includes, camelCase } from 'lodash'


export default
  props:
    event: Object
    eventWindow: Object

  watch:
    '$route.params.sequence_id': 'updateIsFocused'

  data: ->
    isDisabled: false
    isFocused: @updateIsFocused()

  methods:
    updateIsFocused: ->
      @isFocused = parseInt(@$route.params.sequence_id) == @event.sequenceId

    viewed: (viewed) ->
      @event.markAsRead() if viewed

    hasComponent: ->
      includes(threadItemComponents, camelCase(@event.kind))

    debug: ->
      window.Loomio.debug

    removeEvent: -> submitForm @, @event,
      submitFn: @event.removeFromThread
      flashSuccess: 'thread_item.event_removed'

    camelCase: camelCase

  computed:
    canRemoveEvent: ->
      AbilityService.canRemoveEventFromThread(@event)

    isNested: -> @event.isNested()

    indent: ->
      @$vuetify.breakpoint.smAndUp && @event.isNested() && @eventWindow.useNesting

    isUnread: ->
      (Session.user().id != @event.actorId) && @eventWindow.isUnread(@event)

    headline: ->
      @$t eventHeadline(@event, @eventWindow.useNesting),
        author:   @event.actorName() || @$t('common.anonymous')
        username: @event.actorUsername()
        key:      @event.model().key
        title:    eventTitle(@event)
        polltype: @$t(eventPollType(@event)).toLowerCase()

    link: ->
      LmoUrlService.event @event

</script>

<template lang="pug">
div
  .thread-item(:class="{'thread-item--unread': isUnread, 'thread-item--focused': isFocused}" v-observe-visibility="{callback: viewed, once: true}")
    v-layout.lmo-action-dock-wrapper(:id="'sequence-' + event.sequenceId" :class="{'thread-item--indent': indent}")
      .lmo-disabled-form(v-show='isDisabled')
      .thread-item__avatar.mr-3
        user-avatar(v-if='!event.isForkable() && event.actor()' :user='event.actor()' :size='isNested ? "thirtysix" : "medium"')
        v-checkbox.thread-item__is-forking(v-if="event.isForkable()" :disabled="!event.canFork()" @change="event.toggleFromFork()" v-model="event.isForking()")
      v-layout.thread-item__body(column)
        v-layout
          h3.thread-item__title.body-2.d-flex.align-center.wrap(:id="'event-' + event.id")
            div(v-if='debug()')
              mid-dot
              | sid {{event.sequenceId}}
              | pos {{event.position}}
              | pid: {{event.model().parentId}}
              | depth: {{event.depth}}
            slot(name="headline")
              span.thread-item__headline(v-html='headline')
            mid-dot
            router-link.thread-item__link(:to='link')
              time-ago.timeago--inline(:date='event.createdAt')
          button.md-button--tiny(v-if='canRemoveEvent', @click='removeEvent()')
            i.mdi.mdi-delete
        slot
  template(v-if='event.isSurface() && eventWindow.useNesting')
    event-children(:parent-event='event' :parent-event-window='eventWindow')
</template>

<style lang="scss">
@import 'variables';
@import 'utilities';
// @import 'mixins';
.thread-item {
  padding: 4px $cardPaddingSize;
}

.thread-item--focused {
  background-color: var(--v-accent-lighten5);
}

.thread-item--unread {
  padding-left: $cardPaddingSize - 2px;
  border-left: 2px solid var(--v-primary-base);
  &.thread-item--indent {
    padding-left: $cardPaddingSize + 40px;
    // padding-left: 56px; // (42 (indent) - 2 (unread border) + 16 (card padding))
  }
}

.thread-item--indent {
  padding-left: $cardPaddingSize + 42px;
}

.thread-item--indent-margin {
  margin-left: $cardPaddingSize + 42px;
}

.thread-item__body {
  width: 100%;
  min-width: 0;
}

@media (max-width: $tiny-max-px){
  .thread-item__directive {
    margin-left: -42px;
  }
}

.thread-item__footer {
  // @include fontSmall();
  color: $grey-on-white;
  clear: both;
}

.thread-item__actions {
  margin-right: 3px;
  display: inline-block;
}

.thread-item__link:hover  {
  text-decoration: underline;
}

.thread-item__link abbr {
  font-weight: normal;
  color: $grey-on-white;
}

.thread-item__action {
  // @include lmoBtnLink;
  color: $link-color;
}

.thread-item__action--view-edits {
  // @include lmoBtnLink;
  color: $grey-on-white;
}

.thread-item__timestamp {
  display: inline-block;
}
</style>
