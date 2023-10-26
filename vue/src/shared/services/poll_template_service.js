/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let PollTemplateService;
import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import Flash          from '@/shared/services/flash';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import StanceService  from '@/shared/services/stance_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import i18n           from '@/i18n';
import { hardReload } from '@/shared/helpers/window';
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service';

export default new (PollTemplateService = class PollTemplateService {
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
});
