<script lang="coffee">
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'

import { submitForm } from '@/shared/helpers/form'
import { eventHeadline, eventTitle, eventPollType } from '@/shared/helpers/helptext'
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

  watch:
    '$route.params.sequence_id': 'updateIsFocused'

  data: ->
    isDisabled: false
    showCommentForm: false
    parentComment: null
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

    handleReplyButtonClicked: (obj) ->
      @parentComment = obj.eventable
      @showCommentForm = true

    handleCommentSubmitted: ->
      @showCommentForm = false

  computed:
    canRemoveEvent: ->
      AbilityService.canRemoveEventFromThread(@event)

    isNested: -> @event.isNested()

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

    unreadColor: ->
      @$vuetify.theme.primary

    styles: ->
      styles = {'border-color': @$vuetify.theme.primary}
      styles['background-color'] = 'var(--v-accent-lighten5)' if @isFocused
      styles


</script>

<template lang="pug">
div
  .thread-item(:class="{'thread-item--unread': isUnread}" :style="styles" v-observe-visibility="{callback: viewed, once: true}")
    .lmo-flex.lmo-relative.lmo-action-dock-wrapper.lmo-flex--row(:id="'sequence-' + event.sequenceId" :class="{'thread-item--indent': indent}")
      .lmo-disabled-form(v-show='isDisabled')
      .thread-item__avatar.lmo-margin-right
        user-avatar(v-if='!event.isForkable() && event.actor()' :user='event.actor()' :size='isNested ? "thirtysix" : "medium"')
        v-checkbox.thread-item__is-forking(v-if="event.isForkable()" :disabled="!event.canFork()" @change="event.toggleFromFork()" v-model="event.isForking()")
      .thread-item__body.lmo-flex.lmo-flex__horizontal-center.lmo-flex--column
        .thread-item__headline.lmo-flex.lmo-flex--row.lmo-flex__center.lmo-flex__grow.lmo-flex__space-between
          h3.thread-item__title(:id="'event-' + event.id")
            div(v-if='debug()')
              | id: {{event.id}} cpid: {{event.model().parentId}} pid: {{event.parentId}} sid: {{event.sequenceId}} position: {{event.position}} depth: {{event.depth}} unread: {{isUnread}} cc: {{event.childCount}} eventableId: {{event.eventableId}}
              //- | sid: {{event.sequenceId}} position: {{event.position}} commentId: {{event.eventableId}}
            span(v-html='headline')
            | &nbsp;
            span(aria-hidden='true') ·
            | &nbsp;
            router-link.thread-item__link.lmo-pointer(:to='link')
              time-ago.timeago--inline(:date='event.createdAt')
          button.md-button--tiny(v-if='canRemoveEvent', @click='removeEvent()')
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

.thread-item__link abbr {
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
