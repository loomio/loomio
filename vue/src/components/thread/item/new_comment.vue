<script lang="coffee">
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'

import { pick, assign, compact } from 'lodash'
import CommentService from '@/shared/services/comment_service'
import EventService from '@/shared/services/event_service'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    event: Object

  computed:
    commentActions: -> CommentService.actions(@eventable, @)
    eventActions: -> EventService.actions(@event, @)
    eventable: -> @event.model()
    link: -> LmoUrlService.event @event
    dockActions: ->
      if AbilityService.canEditComment(@eventable)
        edit_comment = 'edit_comment'
      else
        reply_to_comment = 'reply_to_comment'
        show_history = 'show_history'

      pick @commentActions, compact ['react', reply_to_comment, edit_comment, show_history]

    menuActions: ->
      if AbilityService.canEditComment(@eventable)
        show_history = 'show_history'
        reply_to_comment = 'reply_to_comment'

      assign(
        pick @commentActions, compact [reply_to_comment, show_history, 'notification_history', 'move_comments', 'translate_comment' , 'delete_comment']
      ,
        pick @eventActions, ['pin_event', 'unpin_event']
      )

  data: ->
    confirmOpts: null
    showReplyForm: false
    newComment: null

</script>

<template lang="pug">
thread-item.new-comment(id="'comment-'+ eventable.id" :event="event")
  template(v-slot:actions)
    v-layout(align-center)
      reaction-display(:model="eventable")
      action-dock(:model='eventable', :actions='dockActions')
      action-menu(:actions='menuActions')
  formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
  document-list(:model='eventable' skip-fetch)
  attachment-list(:attachments="eventable.attachments")
  template(v-slot:append)
    comment-form(v-if="showReplyForm" :comment="newComment" @comment-submitted="showReplyForm = false" @cancel-reply="showReplyForm = false" :autoFocus="true")
</template>
