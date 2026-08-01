import Records        from '@/shared/services/records';
import openModal      from '@/shared/helpers/open_modal';

const icons = {
  matrix: 'mdi-matrix',
  slack: 'mdi-slack',
  discord: 'mdi-discord',
  microsoft: 'mdi-microsoft-teams',
  markdown: 'mdi-chat-processing',
  webex: 'webex'
};

export default new class ChatbotService {
  iconForKind(kind) {
    return icons[kind] || 'mdi-connection';
  }

  iconForChatbot(chatbot) {
    return this.iconForKind(chatbot.kind === 'webhook' ? chatbot.webhookKind : chatbot.kind);
  }

  confirmDestroy(chatbot) {
    const openList = () => openModal({
      component: 'ChatbotList',
      props: { group: chatbot.group() }
    });

    return openModal({
      component: 'ConfirmModal',
      props: {
        confirm: {
          submit: () => chatbot.destroy(),
          successCallback: openList,
          cancelCallback: openList,
          text: {
            title: 'chatbot.delete_chat_integration',
            helptext: 'chatbot.delete_chat_integration_helptext',
            submit: 'common.action.delete',
            flash: 'chatbot.chat_integration_deleted'
          },
          textArgs: { name: chatbot.name }
        }
      }
    });
  }

  addActions(group) {
    return {
      matrix: {
        name: 'chatbot.matrix',
        icon: this.iconForKind('matrix'),
        menu: true,
        canPerform() { return true; },
        perform() {
          return openModal({
            component: 'ChatbotMatrixForm',
            props: {
              chatbot: Records.chatbots.build({
                groupId: group.id,
                kind: "matrix"
              })
            }
          });
        }
      },

      slack: {
        name: 'chatbot.slack',
        icon: this.iconForKind('slack'),
        menu: true,
        canPerform() { return true; },
        perform() {
          return openModal({
            component: 'ChatbotWebhookForm',
            props: {
              chatbot: Records.chatbots.build({
                groupId: group.id,
                kind: "webhook",
                webhookKind: "slack"
              })
            }
          });
        }
      },

      discord: {
        name: 'chatbot.discord',
        icon: this.iconForKind('discord'),
        menu: true,
        canPerform() { return true; },
        perform() {
          return openModal({
            component: 'ChatbotWebhookForm',
            props: {
              chatbot: Records.chatbots.build({
                groupId: group.id,
                kind: "webhook",
                webhookKind: "discord"
              })
            }
          });
        }
      },
              
      microsoft: {
        name: 'chatbot.microsoft_teams',
        icon: this.iconForKind('microsoft'),
        menu: true,
        canPerform() { return true; },
        perform() {
          return openModal({
            component: 'ChatbotWebhookForm',
            props: {
              chatbot: Records.chatbots.build({
                groupId: group.id,
                kind: "webhook",
                webhookKind: "microsoft"
              })
            }
          });
        }
      },

      mattermost: {
        name: 'chatbot.mattermost',
        icon: this.iconForKind('markdown'),
        menu: true,
        canPerform() { return true; },
        perform() {
          return openModal({
            component: 'ChatbotWebhookForm',
            props: {
              chatbot: Records.chatbots.build({
                groupId: group.id,
                kind: "webhook",
                webhookKind: "markdown"
              })
            }
          });
        }
      },

      webex: {
        name: 'chatbot.webex',
        icon: this.iconForKind('webex'),
        menu: true,
        canPerform() { return true; },
        perform() {
          return openModal({
            component: 'ChatbotWebhookForm',
            props: {
              chatbot: Records.chatbots.build({
                groupId: group.id,
                kind: "webhook",
                webhookKind: "webex"
              })
            }
          });
        }
      },
    };
  }
};
