import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'
import openModal from '@/shared/helpers/open_modal'
import Flash from '@/shared/services/flash'

export default new class CommentService
  actions: (comment, vm) ->
    notification_history:
      name: 'action_dock.notification_history'
      icon: 'mdi-alarm-check'
      perform: ->
        openModal
          component: 'AnnouncementHistory'
          props:
            model: comment
      canPerform: -> !comment.discardedAt

    react:
      canPerform: -> !comment.discardedAt && AbilityService.canAddComment(comment.discussion())

    reply_to_comment:
      icon: 'mdi-reply'
      canPerform: -> AbilityService.canRespondToComment(comment)
      perform: ->
        vm.newComment = Records.comments.build
          bodyFormat: "html"
          body: ""
          discussionId: comment.discussion().id
          authorId: Session.user().id
          parentId: comment.id
        vm.showReplyForm = !vm.showReplyForm

    edit_comment:
      name: 'common.action.edit'
      icon: 'mdi-pencil'
      canPerform: -> !comment.discardedAt && comment.authorIs(Session.user()) && AbilityService.canEditComment(comment)
      perform: ->
        openModal
          component: 'EditCommentForm'
          props:
            comment: comment.clone()

    admin_edit_comment:
      name: 'common.action.edit'
      icon: 'mdi-pencil'
      canPerform: ->
        !comment.authorIs(Session.user()) && AbilityService.canEditComment(comment)
      perform: ->
        openModal
          component: 'EditCommentForm'
          props:
            comment: comment.clone()

    translate_comment:
      icon: 'mdi-translate'
      canPerform: ->
        comment.body && AbilityService.canTranslate(comment)
      perform: ->
        Session.user() && comment.translate(Session.user().locale)

    show_history:
      icon: 'mdi-history'
      name: 'action_dock.history'
      menu: true
      canPerform: ->
        comment.edited() && (!comment.discardedAt ||
                             comment.discussion().adminsInclude(Session.user()))
      perform: ->
        openModal
          component: 'RevisionHistoryModal'
          props:
            model: comment

    discard_comment:
      icon: 'mdi-delete'
      name: 'common.action.remove'
      canPerform: -> AbilityService.canDiscardComment(comment)
      perform: ->
        openModal
          component: 'ConfirmModal',
          props:
            confirm:
              submit: -> comment.discard()
              text:
                title: 'discard_comment_dialog.title'
                helptext: 'discard_comment_dialog.question'
                confirm: 'discard_comment_dialog.title'
                flash: 'comment_form.messages.removed'

    undiscard_comment:
      icon: 'mdi-delete-restore'
      name: 'common.action.undo_remove'
      canPerform: -> AbilityService.canUndiscardComment(comment)
      perform: -> comment.undiscard()

    delete_comment:
      icon: 'mdi-delete'
      canPerform: -> AbilityService.canDeleteComment(comment)
      perform: ->
        openModal
          component: 'ConfirmModal',
          props:
            confirm:
              submit: -> comment.destroy()
              text:
                title: 'delete_comment_dialog.title'
                helptext: 'delete_comment_dialog.question'
                confirm: 'delete_comment_dialog.confirm'
                flash: 'comment_form.messages.destroyed'
