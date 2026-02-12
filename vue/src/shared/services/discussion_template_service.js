import Session        from '@/shared/services/session';
import Records        from '@/shared/services/records';
import Flash          from '@/shared/services/flash';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import StanceService  from '@/shared/services/stance_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import { I18n }           from '@/i18n';
import { hardReload } from '@/shared/helpers/window';

export default new class DiscussionTemplateService {
  canEditTemplate(discussionTemplate, group) {
    return group.adminsInclude(Session.user()) ||
      (group.membersCanCreateTemplates && discussionTemplate.authorId === Session.user().id);
  }

  actions(discussionTemplate, group) {
    const service = this;
    return {
      edit_default_template: {
        name: 'poll_common.edit_template',
        icon: 'mdi-pencil',
        menu: true,
        canPerform() { return !discussionTemplate.id && group.adminsInclude(Session.user()); },
        to() {
          return `/discussion_templates/new?template_key=${discussionTemplate.key}&group_id=${group.id}&return_to=${Session.returnTo()}`;
        }
      },

      edit_template: {
        name: 'poll_common.edit_template',
        icon: 'mdi-pencil',
        menu: true,
        canPerform() { return discussionTemplate.id && service.canEditTemplate(discussionTemplate, group); },
        to() {
          return `/discussion_templates/${discussionTemplate.id}?&return_to=${Session.returnTo()}`;
        }
      },

      rearrange: {
        name: 'common.action.rearrange',
        icon: 'mdi-arrow-up-down',
        menu: true,
        canPerform() { return !discussionTemplate.discardedAt && group.adminsInclude(Session.user()); },
        perform() { return EventBus.$emit('sortDiscussionTemplates'); }
      },

      discard: {
        icon: 'mdi-eye-off',
        name: 'common.action.hide',
        menu: true,
        canPerform() { return discussionTemplate.id && !discussionTemplate.discardedAt && service.canEditTemplate(discussionTemplate, group); },
        perform() {
          return Records.remote.post('discussion_templates/discard', {group_id: group.id, id: discussionTemplate.id});
        }
      },

      undiscard: {
        icon: 'mdi-eye',
        name: 'common.action.unhide',
        menu: true,
        canPerform() { return discussionTemplate.id && discussionTemplate.discardedAt && service.canEditTemplate(discussionTemplate, group); },
        perform() {
          return Records.remote.post('discussion_templates/undiscard', {group_id: group.id, id: discussionTemplate.id});
        }
      },

      destroy: {
        icon: 'mdi-delete',
        name: 'common.action.delete',
        menu: true,
        canPerform() { return discussionTemplate.id && service.canEditTemplate(discussionTemplate, group); },
        perform() {
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit() {
                  return discussionTemplate.destroy().then(() => {
                    EventBus.$emit('closeModal');
                    EventBus.$emit('reloadDiscussionTemplates');
                  });
                },
                text: {
                  title: 'common.are_you_sure',
                  helptext: 'discussion_template.confirm_delete',
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
          return !discussionTemplate.id && discussionTemplate.key && !discussionTemplate.discardedAt && group.adminsInclude(Session.user());
        },
        perform() {
          return Records.remote.post('discussion_templates/hide', {group_id: group.id, key: discussionTemplate.key});
        }
      },

      unhide: {
        icon: 'mdi-eye',
        name: 'common.action.unhide',
        menu: true,
        canPerform() {
          return !discussionTemplate.id && discussionTemplate.key && discussionTemplate.discardedAt && group.adminsInclude(Session.user());
        },
        perform() {
          return Records.remote.post('discussion_templates/unhide', {group_id: group.id, key: discussionTemplate.key});
        }
      }
    };
  }
};
