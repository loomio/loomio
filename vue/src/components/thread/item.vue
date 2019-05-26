<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'

import { submitForm } from '@/shared/helpers/form'
import { includes, camelCase } from 'lodash'

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
    actions: [
        name: 'remove-event'
        icon: 'mdi-delete'
        canPerform: => AbilityService.canAddComment(@eventable.discussion())
        perform: => submitForm @, @event,
          submitFn: @event.removeFromThread
          flashSuccess: 'thread_item.event_removed'
        ]

  computed:
    canRemoveEvent: -> AbilityService.canRemoveEventFromThread(@event)

    hasComponent: ->
      includes(threadItemComponents, camelCase(@event.kind))

    isUnread: ->
      (Session.user().id != @event.actorId) && @eventWindow.isUnread(@event)

    indent: ->
      @event.isNested() && @eventWindow.useNesting

    isFocused: -> @eventWindow.discussion.requestedSequenceId == @event.sequenceId

  methods:
    debug: -> window.Loomio.debug

    camelCase: camelCase

    mdColors: ->
      obj = {'border-color': 'primary-500'}
      obj['background-color'] = 'accent-50' if @isFocused
      obj

    handleReplyButtonClicked: (obj) ->
      @parentComment = obj.eventable
      @showCommentForm = true

    handleCommentSubmitted: ->
      @showCommentForm = false

</script>

<template lang="pug">
div
  .thread-item(md-colors='mdColors()', :class="{'thread-item--indent': indent, 'thread-item--unread': isUnread}", in-view='$inview&&event.markAsRead()', in-view-options='{throttle: 200}')
    div(v-if='debug()')
      | id: {{event.id}}cpid: {{event.comment().parentId}}pid: {{event.parentId}}sid: {{event.sequenceId}}position: {{event.position}}depth: {{event.depth}}unread: {{isUnread()}}cc: {{event.childCount}}
    // <md-checkbox ng-if="event.isForkable()" ng-disabled="!event.canFork()" ng-click="event.toggleFromFork()" ng-checked="event.isForking()"></md-checkbox>
    .thread-item__liner(:id="'sequence-' + event.sequenceId")
      .lmo-disabled-form(v-show='isDisabled')
      .thread-item__avatar
        user-avatar(v-if='!event.isForkable() && event.actor()', :user='event.actor()', size='medium')
      .thread-item__main
        thread-item-headline(v-if='!hasComponent' :event="event" :eventable="eventable" :actions="actions" :eventWindow="eventWindow")
        component(v-if='hasComponent' :is='camelCase(event.kind)' @reply-button-clicked="handleReplyButtonClicked" :event='event' :eventable='event.model()' :eventWindow="eventWindow")
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

.thread-item__liner {
  display: flex;
  position: relative;
  flex-direction: row;
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

.thread-item__main {
  display: flex;
  justify-content: center;
  flex-direction: column;
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
