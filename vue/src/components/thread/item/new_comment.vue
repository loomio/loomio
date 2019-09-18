<script lang="coffee">
import Session        from '@/shared/services/session'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import Flash   from '@/shared/services/flash'
import Records from '@/shared/services/records'

import { pick, assign, compact } from 'lodash'
import { listenForTranslations } from '@/shared/helpers/listen'
import openModal      from '@/shared/helpers/open_modal'
import CommentService from '@/shared/services/comment_service'
import EventService from '@/shared/services/event_service'

export default
  components:
    ThreadItem: -> import('@/components/thread/item.vue')

  props:
    event: Object

  computed:
    eventable: -> @event.model()
    link: -> LmoUrlService.event @event
    dockActions: ->
      if AbilityService.canEditComment(@eventable)
        # reply_to_comment = null
        edit_comment = 'edit_comment'
        # show_history = null
      else
        reply_to_comment = 'reply_to_comment'
        # edit_comment = null
        show_history = 'show_history'

      pick CommentService.actions(@eventable, @), compact ['react', reply_to_comment, edit_comment, show_history]

    menuActions: ->
      if AbilityService.canEditComment(@eventable)
        show_history = 'show_history'
        reply_to_comment = 'reply_to_comment'

      assign(
        pick CommentService.actions(@eventable, @), compact [reply_to_comment, show_history, 'notification_history', 'move_comments', 'translate_comment' , 'delete_comment']
      ,
        pick EventService.actions(@event, @), ['pin_event', 'unpin_event']
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
