<style lang="scss">
.add-comment-panel__sign-in-btn { width: 100% }
.add-comment-panel__join-actions button {
  width: 100%;
}

</style>

<script lang="coffee">
Session        = require 'shared/services/session'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

{ scrollTo } = require 'shared/helpers/layout'

module.exports =
  props:
    eventWindow: Object
    parentEvent: Object

  created: ->
    @actor = Session.user()

  mounted: ->
    # EventBus.listen @, 'replyToEvent', (e, event, comment) =>
    #   # if we're in nesting and we're the correct reply OR we're in chronoglogical, always accept parentComment
    #   if (!@eventWindow.useNesting) || (@parentEvent.id == event.id)
    #     @show = true
    #     @$nextTick =>
    #       @isReply = true
    #       EventBus.broadcast @, 'setParentComment', comment
    #
    #   scrollTo('.add-comment-panel textarea', {bottom: true, offset: 200})
    #
    # EventBus.listen @, 'commentSaved', =>
    #   if @parentEvent == @eventWindow.discussion.createdEvent()
    #     @parentComment = null
    #   else
    #     @close()

  data: ->
    # discussion: @eventWindow.discussion
    show: @parentEvent == @eventWindow.discussion.createdEvent()
    isReply: false

  methods:
    signIn: -> ModalService.open 'AuthModal'
    close: -> @show = false
    isLoggedIn: -> AbilityService.isLoggedIn()
    canAddComment: -> AbilityService.canAddComment(@eventWindow.discussion)

  computed:

    indent: -> @eventWindow.useNesting && @isReply
</script>

<template lang="pug">
.add-comment-panel.lmo-card-padding(v-if='show', :class="{'thread-item--indent': indent}")
  .lmo-flex--row(v-if='canAddComment()')
    .thread-item__avatar.lmo-margin-right
      user-avatar(:user='actor', size='medium')
    .thread-item__body.lmo-flex--column.lmo-flex__horizontal-center
      comment-form(:event-window='eventWindow')
  .add-comment-panel__join-actions(v-if='!canAddComment()')
    join-group-button(:group='eventWindow.discussion.group()', v-if='isLoggedIn()', :block='true')
    button.md-primary.md-raised.add-comment-panel__sign-in-btn(v-t="'comment_form.sign_in'", @click='signIn()', v-if='!isLoggedIn()')
</template>
