import EventBus from '@/shared/services/event_bus';
import GroupAbility from '@/shared/abilities/group_ability';
import Session from '@/shared/services/session';
import Records from '@/shared/services/records';
import openModal from '@/shared/helpers/open_modal';
import Flash from '@/shared/services/flash';

export default new class AttachmentService {
  actions(attachment, group) {
    return {
      delete_attachment: {
        icon: 'mdi-delete',
        name: 'common.action.delete',
        canPerform() {
          return attachment.isA('attachment') && GroupAbility.canUpdate(group);
        },
        perform() {
          return EventBus.$emit('openModal', {
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit: () => attachment.destroy(),
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

    };
  }
};
