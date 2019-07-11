<script lang="coffee">
import Session        from '@/shared/services/session'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import Flash   from '@/shared/services/flash'
import Records from '@/shared/services/records'

import { pick, assign } from 'lodash'
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
      pick CommentService.actions(@eventable, @), ['react', 'reply_to_comment', 'show_history']

    menuActions: ->
      assign(
        pick CommentService.actions(@eventable, @), ['edit_comment', 'fork_comment', 'translate_comment' , 'delete_comment']
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
  template(v-slot:top-right)
    action-dock(:model='eventable', :actions='dockActions')
    action-menu(:actions='menuActions')
  formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
  document-list(:model='eventable' skip-fetch)
  attachment-list(:attachments="eventable.attachments")
  //- v-card-actions
  v-layout
    reaction-display(:model="eventable")
    v-spacer
  comment-form(v-if="showReplyForm" :comment="newComment" @comment-submitted="showReplyForm = false" :autoFocus="true")
</template>
