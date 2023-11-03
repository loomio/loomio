import Session        from '@/services/session';
import Records        from '@/services/records';
import Flash          from '@/services/flash';
import EventBus       from '@/services/event_bus';
import AbilityService from '@/services/ability_service';
import StanceService  from '@/services/stance_service';
import LmoUrlService  from '@/services/lmo_url_service';
import openModal      from '@/helpers/open_modal';
import i18n           from '@/i18n';
import { hardReload } from '@/helpers/window';
import RescueUnsavedEditsService from '@/services/rescue_unsaved_edits_service';

export default new class PollTemplateService {
  actions(pollTemplate, group) {
    return {
      edit_default_template: {
        name: 'poll_common.edit_template',
        icon: 'mdi-pencil',
        menu: true,
        canPerform() { return !pollTemplate.id && group.adminsInclude(Session.user()); },
        to() {
          return `/poll_templates/new?template_key=${pollTemplate.key}&group_id=${group.id}&return_to=${Session.returnTo()}`;
        }
      },
        // perform: ->
        //   openModal
        //     component: 'PollTemplateForm'
        //     props:
        //       isModal: true
        //       pollTemplate: pollTemplate.clone()

      edit_template: {
        name: 'poll_common.edit_template',
        icon: 'mdi-pencil',
        menu: true,
        canPerform() { return pollTemplate.id && group.adminsInclude(Session.user()); },
        to() {
          return `/poll_templates/${pollTemplate.id}/edit?&return_to=${Session.returnTo()}`;
        }
      },
        // perform: ->
        //   openModal
        //     component: 'PollTemplateForm'
        //     props:
        //       isModal: true
        //       pollTemplate: pollTemplate.clone()

      move: {
        name: 'common.action.move',
        icon: 'mdi-arrow-up-down',
        menu: true,
        canPerform() { return !pollTemplate.discardedAt && group.adminsInclude(Session.user()); },
        perform() { return EventBus.$emit('sortPollTemplates'); }
      },

      discard: {
        icon: 'mdi-eye-off',
        name: 'common.action.hide',
        menu: true,
        canPerform() { return pollTemplate.id && !pollTemplate.discardedAt && group.adminsInclude(Session.user()); },
        perform() {
          return Records.remote.post('poll_templates/discard', {group_id: group.id, id: pollTemplate.id});
        }
      },

      undiscard: {
        icon: 'mdi-eye',
        name: 'common.action.unhide',
        menu: true,
        canPerform() { return pollTemplate.id && pollTemplate.discardedAt && group.adminsInclude(Session.user()); },
        perform() {
          return Records.remote.post('poll_templates/undiscard', {group_id: group.id, id: pollTemplate.id});
        }
      },

      destroy: {
        icon: 'mdi-delete',
        name: 'common.action.delete',
        menu: true,
        canPerform() { return pollTemplate.id && group.adminsInclude(Session.user()); },
        perform() { 
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit() {
                  return pollTemplate.destroy().then(() => EventBus.$emit('closeModal'));
                },
                text: {
                  title: 'common.are_you_sure',
                  helptext: 'poll_common_form.confirm_delete',
                  submit: 'common.action.delete'
                }
              }
            }
          });
        }
      },

      hide: {
        icon: 'mdi-eye-off',
        name: 'common.action.hide',
        menu: true,
        canPerform() { 
          return !pollTemplate.id && pollTemplate.key && !pollTemplate.discardedAt && group.adminsInclude(Session.user());
        },
        perform() {
          return Records.remote.post('poll_templates/hide', {group_id: group.id, key: pollTemplate.key});
        }
      },

      unhide: {
        icon: 'mdi-eye',
        name: 'common.action.unhide',
        menu: true,
        canPerform() { 
          return !pollTemplate.id && pollTemplate.key && pollTemplate.discardedAt && group.adminsInclude(Session.user());
        },
        perform() {
          return Records.remote.post('poll_templates/unhide', {group_id: group.id, key: pollTemplate.key});
        }
      }
    };
  }
};
