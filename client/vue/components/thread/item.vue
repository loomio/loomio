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

<script lang="coffee">
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
I18n           = require 'shared/services/i18n'

{ submitForm } = require 'shared/helpers/form'
{ eventHeadline, eventTitle, eventPollType } = require 'shared/helpers/helptext'

threadItemComponents = [
  'newComment',
  'outcomeCreated',
  'pollCreated',
  'stanceCreated'
 ]

module.exports =
  props:
    event: Object
    eventWindow: Object
  # created: ->
  #   if $scope.event.isSurface() && $scope.eventWindow.useNesting
  #     EventBus.listen $scope, 'replyButtonClicked', (e, parentEvent, comment) ->
  #       if $scope.event.id == parentEvent.id
  #         $scope.eventWindow.max = false
  #         EventBus.broadcast $scope, 'showReplyForm', comment
  data: ->
    isDisabled: false
  methods:
    hasComponent: ->
      _.includes(threadItemComponents, _.camelCase(@event.kind))

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
      I18n.t eventHeadline(@event, @eventWindow.useNesting),
        author:   @event.actorName() || I18n.t('common.anonymous')
        username: @event.actorUsername()
        key:      @event.model().key
        title:    eventTitle(@event)
        polltype: I18n.t(eventPollType(@event)).toLowerCase()

    link: ->
      LmoUrlService.event @event
</script>

<template>
      <div>
        <div
          md-colors="mdColors()"
          class="thread-item"
          :class="{'thread-item--indent': indent(), 'thread-item--unread': isUnread()}"
          in-view="$inview&amp;&amp;event.markAsRead()"
          in-view-options="{throttle: 200}"
        >
          <div :id="'sequence-' + event.sequenceId"
            class="lmo-flex lmo-relative lmo-action-dock-wrapper lmo-flex--row"
          >
            <div v-show="isDisabled" class="lmo-disabled-form"></div>
            <div class="thread-item__avatar lmo-margin-right">
              <user-avatar v-if="!event.isForkable() && event.actor()" :user="event.actor()" size="small"></user-avatar>
              <!-- <md-checkbox ng-if="event.isForkable()" ng-disabled="!event.canFork()" ng-click="event.toggleFromFork()" ng-checked="event.isForking()"></md-checkbox> -->
            </div>
            <div class="thread-item__body lmo-flex lmo-flex__horizontal-center lmo-flex--column">
              <div class="thread-item__headline lmo-flex lmo-flex--row lmo-flex__center lmo-flex__grow lmo-flex__space-between">
                <h3 :id="'event-' + event.id"
                  class="thread-item__title"
                >
                  <div v-if="debug()">
                    id: {{event.id}}cpid: {{event.comment().parentId}}pid: {{event.parentId}}sid: {{event.sequenceId}}position: {{event.position}}depth: {{event.depth}}unread: {{isUnread()}}cc: {{event.childCount}}
                  </div>
                  <span v-html="headline()"></span>
                  <span aria-hidden="true">·</span>
                  <a
                    :href="link()"
                    class="thread-item__link lmo-pointer"
                  >
                    <time-ago :date="event.createdAt" class="timeago--inline"></time-ago>
                  </a>
                </h3>
                <button v-if="canRemoveEvent()" @click="removeEvent()" class="md-button--tiny"><i class="mdi mdi-delete"></i></button>
              </div>
              <component v-if="hasComponent()" :is="_.camelCase(event.kind)" :event='event' :eventable='event.model()'></component>
            </div>
          </div>
        </div>
        <template v-if="event.isSurface() && eventWindow.useNesting">
          <event-children
            :parent-event="event"
            :parent-event-window="eventWindow"
          ></event-children>
          <add-comment-panel
            :parent-event="event"
            :event-window="eventWindow"
          ></add-comment-panel>
        </template>
      </div>
</template>
