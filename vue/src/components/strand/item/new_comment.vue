<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'

import { pick, assign, compact } from 'lodash'
import CommentService from '@/shared/services/comment_service'
import EventService from '@/shared/services/event_service'
import Session from '@/shared/services/session'

export default
  props:
    event: Object
    eventable: Object
    isReturning: Boolean

  data: ->
    confirmOpts: null
    showReplyForm: false
    newComment: null
    commentActions: CommentService.actions(@eventable, @)
    eventActions: EventService.actions(@event, @)

  computed:
    dockActions: ->
      if AbilityService.canEditOwnComment(@eventable)
        edit_comment = 'edit_comment'
      else
        reply_to_comment = 'reply_to_comment'
        show_history = 'show_history'

      assign(
        pick @commentActions, compact ['react', 'translate_comment', reply_to_comment, edit_comment, show_history]
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
        pick @commentActions, compact [reply_to_comment, 'admin_edit_comment', show_history, 'notification_history', 'discard_comment', 'undiscard_comment']
      )

</script>

<template lang="pug">
section.strand-item__new-comment.new-comment(:id="'comment-'+ eventable.id")
  strand-item-headline(:event="event" :eventable="eventable")
  formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
  link-previews(:model="eventable")
  document-list(:model='eventable')
  attachment-list(:attachments="eventable.attachments")
  action-dock(:model='eventable' :actions='dockActions' :menu-actions='menuActions' small)
  comment-form(v-if="showReplyForm" :comment="newComment" avatar-size="36" @comment-submitted="showReplyForm = false" @cancel-reply="showReplyForm = false" autofocus)
</template>
