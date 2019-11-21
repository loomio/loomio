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
      canPerform: -> true

    react:
      canPerform: -> AbilityService.canAddComment(comment.discussion())

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
      canPerform: -> AbilityService.canEditComment(comment)
      perform: ->
        openModal
          component: 'EditCommentForm'
          props:
            comment: comment.clone()

    move_comments:
      icon: 'mdi-call-split'
      canPerform: -> AbilityService.canMoveComment(comment)
      perform: -> comment.createdEvent().toggleFromFork()

    translate_comment:
      icon: 'mdi-translate'
      canPerform: ->
        comment.body && AbilityService.canTranslate(comment)
      perform: ->
        Session.user() && comment.translate(Session.user().locale)

    show_history:
      icon: 'mdi-history'
      name: 'action_dock.edited'
      menu: true
      canPerform: -> comment.edited()
      perform: ->
        openModal
          component: 'RevisionHistoryModal'
          props:
            model: comment

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
