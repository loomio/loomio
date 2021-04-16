<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'

import { pick, assign, compact } from 'lodash'
import CommentService from '@/shared/services/comment_service'
import EventService from '@/shared/services/event_service'
import Session from '@/shared/services/session'

export default
  props:
    event: Object
    isReturning: Boolean

  computed:
    commentActions: -> CommentService.actions(@eventable, @)
    eventActions: -> EventService.actions(@event, @)
    eventable: -> @event.model()
    dockActions: ->
      if AbilityService.canEditOwnComment(@eventable)
        edit_comment = 'edit_comment'
      else
        reply_to_comment = 'reply_to_comment'
        show_history = 'show_history'

      assign(
        pick @commentActions, compact ['react', reply_to_comment, 'translate_comment', edit_comment, show_history]
      ,
        pick @eventActions, []
      )

    menuActions: ->
      if AbilityService.canEditOwnComment(@eventable)
        show_history = 'show_history'
        reply_to_comment = 'reply_to_comment'

      assign(
        pick @eventActions, ['pin_event', 'unpin_event', 'move_event', 'copy_url']
      ,
        pick @commentActions, compact [reply_to_comment, show_history, 'admin_edit_comment', 'notification_history', 'discard_comment', 'undiscard_comment']
      )

  data: ->
    confirmOpts: null
    showReplyForm: false
    newComment: null

</script>

<template lang="pug">
section.strand-item__new-comment.new-comment(id="'comment-'+ eventable.id" :event="event" :is-returning="isReturning")
  strand-item-headline(:event="event" :eventable="eventable")
  formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
  document-list(:model='eventable' skip-fetch)
  attachment-list(:attachments="eventable.attachments")
  action-dock(:model='eventable' :actions='dockActions' :menu-actions='menuActions')
  comment-form(v-if="showReplyForm" :comment="newComment" avatar-size="36" @comment-submitted="showReplyForm = false" @cancel-reply="showReplyForm = false" autofocus)
</template>
