import EventBus from '@/services/event_bus';
import AbilityService from '@/services/ability_service';
import Session from '@/services/session';
import Records from '@/services/records';
import openModal from '@/helpers/open_modal';
import Flash from '@/services/flash';

export default new class AttachmentService {
  actions(attachment) {
    return {
      delete_attachment: {
        icon: 'mdi-delete',
        name: 'common.action.delete',
        canPerform() {
          return attachment.isA('attachment') && AbilityService.canAdminister(attachment.group());
        },
        perform() {
          return EventBus.$emit('openModal', {
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit: attachment.destroy,
                text: {
                  title: 'comment_form.attachments.remove_attachment',
                  helptext: 'group_files_panel.delete_confirmation',
                  submit: 'common.action.delete',
                  flash: 'poll_common_delete_modal.success'
                }
              }
            }
          }
          );
        }
      },

      delete_document: {
        icon: 'mdi-delete',
        name: 'common.action.delete',
        canPerform() {
          return attachment.isA('document') && AbilityService.canAdminister(attachment.group());
        },
        perform() {
          return EventBus.$emit('openModal', {
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit: attachment.destroy,
                text: {
                  title: 'comment_form.attachments.remove_attachment',
                  helptext: 'group_files_panel.delete_confirmation',
                  submit: 'common.action.delete',
                  flash: 'poll_common_delete_modal.success'
                }
              }
            }
          }
          );
        }
      }
    };
  }
};
