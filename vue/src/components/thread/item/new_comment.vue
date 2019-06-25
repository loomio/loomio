<script lang="coffee">
import Session        from '@/shared/services/session'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import Flash   from '@/shared/services/flash'
import ModalService   from '@/shared/services/modal_service'
import CommentModalMixin from '@/mixins/comment_modal.coffee'
import ConfirmModalMixin from '@/mixins/confirm_modal'
import RevisionHistoryModalMixin from '@/mixins/revision_history_modal'

import { listenForTranslations } from '@/shared/helpers/listen'

export default
  mixins: [
    CommentModalMixin,
    ConfirmModalMixin,
    RevisionHistoryModalMixin
  ]
  props:
    event: Object
    eventable: Object

  data: ->
    confirmOpts:
      submit: @eventable.destroy
      text:
        title:    'delete_comment_dialog.title'
        helptext: 'delete_comment_dialog.question'
        confirm:  'delete_comment_dialog.confirm'
        flash:    'comment_form.messages.destroyed'
    actions: [
      name: 'react'
      canPerform: => AbilityService.canAddComment(@eventable.discussion())
    ,
      name: 'reply_to_comment'
      icon: 'mdi-reply'
      canPerform: => AbilityService.canRespondToComment(@eventable)
      perform:    =>
        @$emit('reply-button-clicked', {event: @event, eventable: @eventable})
    ,
      name: 'edit_comment'
      icon: 'mdi-pencil'
      canPerform: => @canEditComment(@eventable)
      perform:    => @openEditCommentModal(@eventable)
    ,
      name: 'fork_comment'
      icon: 'mdi-call-split'
      canPerform: => AbilityService.canForkComment(@eventable)
      perform:    =>
        # EventBus.broadcast $rootScope, 'toggleSidebar', false
        @event.toggleFromFork()
    ,
      name: 'translate_comment'
      icon: 'mdi-translate'
      canPerform: => @eventable.body && AbilityService.canTranslate(@eventable) && !@translation
      perform:    => @eventable.translate(Session.user().locale)
    ,
    #   name: 'copy_url'
    #   icon: 'mdi-link'
    #   canPerform: => clipboard.supported
    #   perform:    =>
    #     clipboard.copyText(LmoUrlService.event(@event, {}, absolute: true))
    #     Flash.success("action_dock.comment_copied")
    # ,
      name: 'show_history'
      icon: 'mdi-history'
      canPerform: => @eventable.edited()
      perform:    => @openRevisionHistoryModal(@eventable)
    ,
      name: 'delete_comment'
      icon: 'mdi-delete'
      canPerform: => AbilityService.canDeleteComment(@eventable)
      perform:    => @openConfirmModal(@confirmOpts)
    ]

</script>

<template lang="pug">
  .new-comment(id="'comment-'+ eventable.id")
    formatted-text.thread-item__body.new-comment__body(:model="eventable" column="body")
    document-list(:model='eventable', :skip-fetch='true')
    attachment-list(:attachments="eventable.attachments")
    v-card-actions
      v-layout(wrap)
        reaction-display(:model="eventable")
        v-spacer
        action-dock(:model='eventable', :actions='actions')
</template>
