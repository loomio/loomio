<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'

import { submitForm } from '@/shared/helpers/form'
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext'

import _includes from 'lodash/includes'
import _camelCase from 'lodash/camelCase'

import NewComment from '@/components/thread/item/new_comment.vue'
import PollCreated from '@/components/thread/item/poll_created.vue'
import StanceCreated from '@/components/thread/item/stance_created.vue'
import OutcomeCreated from '@/components/thread/item/outcome_created.vue'

threadItemComponents = [
  'newComment',
  'outcomeCreated',
  'pollCreated',
  'stanceCreated'
 ]

export default
  components:
    NewComment: NewComment
    PollCreated: PollCreated
    StanceCreated: StanceCreated
    OutcomeCreated: OutcomeCreated
  props:
    event: Object
    eventWindow: Object
  data: ->
    isDisabled: false
    showCommentForm: false
    parentComment: null

  watch:
    showCommentForm: (a,b) ->
      console.log "showCommentForm", a, b
  methods:
    hasComponent: ->
      _includes(threadItemComponents, _camelCase(@event.kind))

    debug: -> window.Loomio.debug

    canRemoveEvent: -> AbilityService.canRemoveEventFromThread(@event)

    removeEvent: -> submitForm @, @event,
      submitFn: @event.removeFromThread
      flashSuccess: 'thread_item.event_removed'

    mdColors: ->
      obj = {'border-color': 'primary-500'}
      obj['background-color'] = 'accent-50' if @isFocused
      obj

    isFocused: -> @eventWindow.discussion.requestedSequenceId == @event.sequenceId

    indent: ->
      @event.isNested() && @eventWindow.useNesting

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

    camelCase: (str) ->
      _camelCase(str)

    handleReplyButtonClicked: (obj) ->
      console.log "reply button clicked", @event
      @parentComment = obj.eventable
      @showCommentForm = true

    handleCommentSubmitted: ->
      @showCommentForm = false

</script>

<template lang="pug">
div
  .thread-item(md-colors='mdColors()', :class="{'thread-item--indent': indent(), 'thread-item--unread': isUnread()}", in-view='$inview&&event.markAsRead()', in-view-options='{throttle: 200}')
    .lmo-flex.lmo-relative.lmo-action-dock-wrapper.lmo-flex--row(:id="'sequence-' + event.sequenceId")
      .lmo-disabled-form(v-show='isDisabled')
      .thread-item__avatar.lmo-margin-right
        user-avatar(v-if='!event.isForkable() && event.actor()', :user='event.actor()', size='medium')
        // <md-checkbox ng-if="event.isForkable()" ng-disabled="!event.canFork()" ng-click="event.toggleFromFork()" ng-checked="event.isForking()"></md-checkbox>
      .thread-item__body.lmo-flex.lmo-flex__horizontal-center.lmo-flex--column
        .thread-item__headline.lmo-flex.lmo-flex--row.lmo-flex__center.lmo-flex__grow.lmo-flex__space-between
          h3.thread-item__title(:id="'event-' + event.id")
            div(v-if='debug()')
              | id: {{event.id}}cpid: {{event.comment().parentId}}pid: {{event.parentId}}sid: {{event.sequenceId}}position: {{event.position}}depth: {{event.depth}}unread: {{isUnread()}}cc: {{event.childCount}}
            span(v-html='headline()')
            |
            |
            span(aria-hidden='true') ·
            |
            |
            router-link.thread-item__link.lmo-pointer(:to='link()')
              time-ago.timeago--inline(:date='event.createdAt')
          button.md-button--tiny(v-if='canRemoveEvent()', @click='removeEvent()')
            i.mdi.mdi-delete
        component(v-if='hasComponent()' :is='camelCase(event.kind)' @reply-button-clicked="handleReplyButtonClicked" :event='event', :eventable='event.model()')
    comment-form(v-if="showCommentForm" @comment-submitted="handleCommentSubmitted" :parentComment="parentComment" :discussion="eventWindow.discussion")
  template(v-if='event.isSurface() && eventWindow.useNesting')
    event-children(:parent-event='event' :parent-event-window='eventWindow')
</template>

<style lang="scss">
@import 'variables';
@import 'mixins';
.thread-item {
  padding: 4px $cardPaddingSize;
}

.thread-item--unread {
  padding-left: $cardPaddingSize - 2px;
  border-left: 2px solid;
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

.thread-item__title {
  /* these styles break with BEM but they keep the translations clean*/
  color: $grey-on-white;
  strong, a {
    color: $primary-text-color;
    @include md-body-2;
  }
  strong:nth-child(2) {
    font-weight: normal;
    color: $grey-on-white;
  }
}


.thread-item__headline {
  min-height: 28px;
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
  @include fontSmall();
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

.thread-item__link abbr span {
  font-weight: normal;
  color: $grey-on-white;
}

.thread-item__action {
  @include lmoBtnLink;
  color: $link-color;
}

.thread-item__action--view-edits {
  @include lmoBtnLink;
  color: $grey-on-white;
}

.thread-item__timestamp {
  display: inline-block;
}
</style>
