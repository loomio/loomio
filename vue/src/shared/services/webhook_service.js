/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let WebhookService;
import Records        from '@/shared/services/records';
import AppConfig      from '@/shared/services/app_config';
import openModal      from '@/shared/helpers/open_modal';
import EventBus from '@/shared/services/event_bus';
import I18n from '@/i18n';

export default new (WebhookService = class WebhookService {
  addAction(group) {
    return {
      name: 'webhook.add_integration',
      icon: 'mdi-plus',
      canPerform() { return true; },
      perform() {
        return EventBus.$emit('openModal', {
          component: 'WebhookForm',
          props: {
            webhook: Records.webhooks.build({groupId: group.id})
          }
        }
        );
      }
    };
  }

  webhookActions(webhook) {
    return {
      showApiDocs: {
        name: 'webhook.show_docs',
        icon: 'mdi-key-variant',
        canPerform() {
          return webhook.permissions.length;
        },
        perform() {
          return window.open(AppConfig.baseUrl + `help/api?api_key=${webhook.token}`, '_blank');
        }
      },

      editWebhook: {
        name: 'common.action.edit',
        icon: 'mdi-pencil',
        canPerform() { return true; },
        perform() {
          return EventBus.$emit('openModal', {
            component: 'WebhookForm',
            props: {
              webhook
            }
          }
          );
        }
      },

      destroyWebhook: {
        name: 'common.action.delete',
        icon: 'mdi-delete',
        canPerform() { return true; },
        perform() {
          return EventBus.$emit('openModal', {
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit: webhook.destroy,
                text: {
                  title: 'webhook.remove',
                  raw_helptext: I18n.t('webhook.confirm_remove', {name: webhook.name}),
                  flash: 'webhook.removed'
                }
              }
            }
          }
          );
        }
      }
    };
  }
});
