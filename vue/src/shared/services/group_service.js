/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let GroupService;
import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import Flash         from '@/shared/services/flash';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import AppConfig      from '@/shared/services/app_config';
import i18n from '@/i18n';
import { hardReload } from '@/shared/helpers/window';

export default new (GroupService = class GroupService {
  actions(group) {
    const membership = group.membershipFor(Session.user());
    
    // email_to_group:
    //   name: 'email_to_group.email_to_group_address'
    //   icon: 'mdi-send'
    //   menu: true
    //   canPerform: -> AbilityService.canStartThread(group)
    //   perform: ->
    //     openModal
    //       component: 'EmailToGroupSettings'
    //       props:
    //         group: group

    return {
      translate_group: {
        name: 'common.action.translate',
        icon: 'mdi-translate',
        dock: 2,
        canPerform() {
          return group.description && AbilityService.canTranslate(group);
        },
        perform() {
          return Session.user() && group.translate(Session.user().locale);
        }
      },

      edit_group: {
        name: 'group_page.options.edit_group',
        icon: 'mdi-cog',
        menu: true,
        canPerform() {
          return AbilityService.canEditGroup(group);
        },
        perform() {
          return openModal({
            component: 'GroupForm',
            props: {
              group: group.clone()
            }
          });
        }
      },

      change_volume: {
        name: 'user_dropdown.email_settings',
        icon: 'mdi-email',
        menu: true,
        canPerform() {
          return AbilityService.canChangeGroupVolume(group);
        },
        perform() {
          return openModal({
            component: 'ChangeVolumeForm',
            props: {
              model: membership
            }
          });
        }
      },

      edit_tags: { 
        icon: 'mdi-tag-outline',
        name: 'loomio_tags.card_title',
        menu: true,
        canPerform() { return AbilityService.canAdminister(group); },
        perform() {
          return EventBus.$emit('openModal', {
            component: 'TagsSelect',
            props: {
              group
            }
          }
          );
        }
      },

      become_coordinator: {
        name: 'group_page.options.become_coordinator',
        icon: 'mdi-shield-star',
        menu: true,
        canPerform() {
          return membership && (membership.admin === false) &&
            ((group.adminMembershipsCount === 0) || group.parentOrSelf().adminsInclude(Session.user()));
        },
        perform() {
          return Records.memberships.makeAdmin(membership).then(() => Flash.success("memberships_page.messages.make_admin_success", {name: Session.user().name}));
        }
      },

      chatbots: {
        name: 'chatbot.chatbots',
        icon: 'mdi-robot',
        menu: true,
        canPerform() {
          return group.adminsInclude(Session.user());
        },
        perform() {
          return openModal({
            component: 'ChatbotList',
            props: {
              group
            }
          });
        }
      },

      webhooks: {
        name: 'webhook.api_keys',
        icon: 'mdi-key-variant',
        menu: true,
        canPerform() {
          return group.adminsInclude(Session.user());
        },
        perform() {
          return openModal({
            component: 'WebhookList',
            props: {
              group
            }
          });
        }
      },

      api_docs: {
        name: 'common.api_docs',
        icon: 'mdi-webhook',
        menu: true,
        canPerform() { return group.adminsInclude(Session.user()); },
        perform() { 
          return hardReload(`/help/api2/?group_id=${group.id}`);
        }
      },

      group_stats: {
        name: 'group_page.stats',
        icon: 'mdi-chart-bar',
        menu: true,
        canPerform() {
          return AbilityService.canAdminister(group);
        },
        perform() {
          return window.open(`${AppConfig.baseUrl}g/${group.key}/stats?export=1`, "_blank");
        }
      },

      export_data: {
        name: 'group_page.options.export_data',
        icon: 'mdi-database-export',
        menu: true,
        canPerform() {
          return membership && group.adminsInclude(Session.user());
        },
        perform() {
          return openModal({
            component: 'ExportDataModal',
            props: {
              group
            }
          });
        }
      },

      manage_subscription: {
        name: 'subscription_status.manage_subscription',
        icon: 'mdi-credit-card-outline',
        menu: true,
        perform() {
          return window.location = `/upgrade/${group.id}`;
        },
        canPerform() {
          return AppConfig.features.app.subscriptions &&
          group.isParent() &&
          group.adminsInclude(Session.user());
        }
      },

      leave_group: {
        name: 'group_page.options.leave_group',
        icon: 'mdi-exit-to-app',
        menu: true,
        canPerform() {
          return AbilityService.canRemoveMembership(membership);
        },
        perform() {
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit() {
                  return membership.destroy().then(() => Records.discussions.find({groupId: membership.groupId}).forEach(d => d.update({discussionReaderUserId: null})));
                },

                text: {
                  title:    'leave_group_form.title',
                  helptext: 'leave_group_form.question',
                  confirm:  'leave_group_form.submit',
                  flash:    'group_page.messages.leave_group_success'
                },
                redirect: '/dashboard'
              }
            }
          });
        }
      },

      destroy_group: {
        name: 'delete_group_modal.title',
        icon: 'mdi-delete',
        menu: true,
        canPerform() {
          return AbilityService.canArchiveGroup(group);
        },
        perform() {
          const confirmText = group.handle || group.name.trim();
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit: group.destroy,
                text: {
                  title:    (group.isParent() && 'delete_group_modal.title') || 'delete_group_modal.subgroup_title',
                  helptext: (group.isParent() && 'delete_group_modal.parent_body') || 'delete_group_modal.body', 
                  raw_confirm_text_placeholder: i18n.t('delete_group_modal.confirm', {name: confirmText}),
                  confirm_text: confirmText,
                  flash:    'delete_group_modal.success',
                  submit:   'delete_group_modal.title'
                },
                redirect:   '/dashboard'
              }
            }
          });
        }
      }
    };
  }
});
