import EventBus from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Session from '@/shared/services/session'
import Records from '@/shared/services/records'
import openModal from '@/shared/helpers/open_modal'
import Flash from '@/shared/services/flash'

export default new class AttachmentService
  actions: (attachment) ->
    delete_attachment:
      icon: 'mdi-delete'
      name: 'common.action.delete'
      canPerform: ->
        attachment.isA('attachment') && AbilityService.canAdminister(attachment.group())
      perform: ->
        EventBus.$emit 'openModal',
          component: 'ConfirmModal'
          props:
            confirm:
              submit: attachment.destroy
              text:
                title: 'comment_form.attachments.remove_attachment'
                helptext: 'group_files_panel.delete_confirmation'
                submit: 'common.action.delete'
                flash: 'poll_common_delete_modal.success'
