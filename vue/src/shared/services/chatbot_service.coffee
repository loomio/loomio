import Records        from '@/shared/services/records'
import AppConfig      from '@/shared/services/app_config'
import openModal      from '@/shared/helpers/open_modal'
import EventBus from '@/shared/services/event_bus'
import I18n from '@/i18n'

export default new class ChatbotService
  addActions: (group) ->
    matrix:
      name: 'chatbot.matrix'
      icon: 'mdi-matrix'
      menu: true
      canPerform: -> true
      perform: ->
        openModal
          component: 'ChatbotMatrixForm'
          props:
            chatbot: Records.chatbots.build
              groupId: group.id
              kind: "matrix"

    slack:
      name: 'chatbot.slack'
      icon: 'mdi-slack'
      menu: true
      canPerform: -> true
      perform: ->
        openModal
          component: 'ChatbotWebhookForm'
          props:
            chatbot: Records.chatbots.build
              groupId: group.id
              kind: "webhook"
              webhookKind: "slack"

    discord:
      name: 'chatbot.discord'
      icon: 'mdi-discord'
      menu: true
      canPerform: -> true
      perform: ->
        openModal
          component: 'ChatbotWebhookForm'
          props:
            chatbot: Records.chatbots.build
              groupId: group.id
              kind: "webhook"
              webhookKind: "discord"
              
    microsoft:
      name: 'chatbot.microsoft_teams'
      icon: 'mdi-microsoft-teams'
      menu: true
      canPerform: -> true
      perform: ->
        openModal
          component: 'ChatbotWebhookForm'
          props:
            chatbot: Records.chatbots.build
              groupId: group.id
              kind: "webhook"
              webhookKind: "microsoft"

    mattermost:
      name: 'chatbot.mattermost'
      icon: 'mdi-chat-processing'
      menu: true
      canPerform: -> true
      perform: ->
        openModal
          component: 'ChatbotWebhookForm'
          props:
            chatbot: Records.chatbots.build
              groupId: group.id
              kind: "webhook"
              webhookKind: "markdown"
