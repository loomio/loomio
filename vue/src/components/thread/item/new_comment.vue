<script lang="coffee">
import Session        from '@/shared/services/session'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import Flash   from '@/shared/services/flash'
import Records from '@/shared/services/records'

import { pick } from 'lodash'
import { listenForTranslations } from '@/shared/helpers/listen'
import openModal      from '@/shared/helpers/open_modal'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    event: Object
    eventWindow: Object

  methods:
    actions: (event, comment) ->
      react:
        canPerform: => AbilityService.canAddComment(comment.discussion())

      reply_to_comment:
        icon: 'mdi-reply'
        canPerform: => AbilityService.canRespondToComment(comment)
        perform: =>
          @newComment = Records.comments.build
            bodyFormat: "html"
            body: ""
            discussionId: comment.discussion().id
            authorId: Session.user().id
            parentId: comment.id
          @showReplyForm = true

      edit_comment:
        icon: 'mdi-pencil'
        canPerform: => AbilityService.canEditComment(comment)
        perform: ->
          openModal
            component: 'EditCommentForm'
            props:
              comment: comment.clone()

      fork_comment:
        icon: 'mdi-call-split'
        canPerform: => AbilityService.canForkComment(comment)
        perform: => event.toggleFromFork()

      translate_comment:
        icon: 'mdi-translate'
        canPerform: => comment.body && AbilityService.canTranslate(comment) && !@translation
        perform:    => comment.translate(Session.user().locale)

      show_history:
        icon: 'mdi-history'
        menu: true
        canPerform: => comment.edited()
        perform: =>
          openModal
            component: 'RevisionHistoryModal'
            props:
              model: comment

      delete_comment:
        icon: 'mdi-delete'
        canPerform: => AbilityService.canDeleteComment(comment)
        perform: =>
          openModal
            component: 'ConfirmModal',
            props:
              confirm:
                submit: -> comment.destroy()
                text:
                  title:    'delete_comment_dialog.title'
                  helptext: 'delete_comment_dialog.question'
                  confirm:  'delete_comment_dialog.confirm'
                  flash:    'comment_form.messages.destroyed'

      pin_event:
        icon: 'mdi-pin'
        canPerform: => AbilityService.canPinEvent(event)
        perform: => event.pin().then => Flash.success('activity_card.event_pinned')

      unpin_event:
        icon: 'mdi-pin-off'
        canPerform: => AbilityService.canUnpinEvent(event)
        perform: => event.unpin().then => Flash.success('activity_card.event_unpinned')

  computed:
    eventable: -> @event.model()
    link: -> LmoUrlService.event @event
    dockActions: ->
      pick @actions(@event, @eventable), ['react', 'reply_to_comment', 'show_history']

    menuActions: ->
      pick @actions(@event, @eventable), ['fork_comment', 'translate_comment', 'edit_comment', 'delete_comment', 'pin_event', 'unpin_event']

  data: ->
    confirmOpts: null
    showReplyForm: false
    newComment: null

</script>

<template lang="pug">
thread-item.new-comment(id="'comment-'+ eventable.id" :event="event" :event-window="eventWindow")
  formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
  document-list(:model='eventable' skip-fetch)
  attachment-list(:attachments="eventable.attachments")
  v-card-actions
    v-spacer
    reaction-display(:model="eventable")
    space
    action-dock(:model='eventable', :actions='dockActions')
    action-menu(:model='eventable', :actions='menuActions')

  comment-form(v-if="showReplyForm" :comment="newComment" @comment-submitted="showReplyForm = false" :autoFocus="true")
</template>
