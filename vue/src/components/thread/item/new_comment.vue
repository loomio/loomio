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
    eventWindow: Object

  computed:
    eventable: -> @event.model()
    link: -> LmoUrlService.event @event
    dockActions: ->
      if AbilityService.canEditComment(@eventable)
        edit_comment = 'edit_comment'
        show_history = null
      else
        edit_comment = null
        show_history = 'show_history'

      pick CommentService.actions(@eventable, @), compact ['react', 'reply_to_comment', edit_comment, show_history]

    menuActions: ->
      if AbilityService.canEditComment(@eventable)
        show_history = 'show_history'

      assign(
        pick CommentService.actions(@eventable, @), compact [show_history, 'fork_comment', 'translate_comment' , 'delete_comment']
      ,
        pick EventService.actions(@event, @), ['pin_event', 'unpin_event']
      )

  data: ->
    confirmOpts: null
    showReplyForm: false
    newComment: null

</script>

<template lang="pug">
thread-item.new-comment(id="'comment-'+ eventable.id" :event="event" :event-window="eventWindow")
  template(v-slot:actions)
    action-dock(:model='eventable', :actions='dockActions')
    action-menu(:actions='menuActions')
  formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
  document-list(:model='eventable' skip-fetch)
  attachment-list(:attachments="eventable.attachments")
  reaction-display(:model="eventable")
  comment-form(v-if="showReplyForm" :comment="newComment" @comment-submitted="showReplyForm = false" :autoFocus="true")
</template>
