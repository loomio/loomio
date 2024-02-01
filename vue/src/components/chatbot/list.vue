<script lang="js">
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import ChatbotService from '@/shared/services/chatbot_service';
import Records from '@/shared/services/records';
import Flash  from '@/shared/services/flash';
import openModal from '@/shared/helpers/open_modal';

export default {
  props: {
    group: Object
  },

  data() {
    return {
      chatbots: [],
      kinds: ['matrix', 'slack', 'discord', 'mattermost', 'teams'],
      loading: true,
      addActions: {},
      icons: {
        matrix: 'mdi-matrix',
        slack: 'mdi-slack',
        discord: 'mdi-discord',
        mattermost: 'mdi-chat-processing',
        teams: 'mdi-microsoft-teams'
      }
    };
  },

  mounted() {
    this.addActions = ChatbotService.addActions(this.group);

    this.watchRecords({
      collections: ["chatbots"],
      query: records => {
        this.chatbots = Records.chatbots.find({groupId: this.group.id});
      }
    });

    Records.chatbots.fetch({params: {group_id: this.group.id}}).then(() => {
      this.loading = false;
    });
  },

  methods: {
    deleteChatbot(bot) {
      bot.destroy();
    },

    editChatbot(bot) {
      if (bot.kind === "webhook") {
        openModal({
          component: 'ChatbotWebhookForm',
          props: {
            chatbot: bot
          }
        });
      } else {
        openModal({
          component: 'ChatbotMatrixForm',
          props: {
            chatbot: bot
          }
        });
      }
    }
  }
};

</script>
<template lang="pug">
v-card.chatbot-list
  v-card-title
    h1.text-h5(tabindex="-1") Chatbots
    v-spacer
    dismiss-modal-button
  v-card-text
    loading(v-if="loading")
    template(v-if="!loading")
      v-list-item(v-for="bot in chatbots" :key="bot.id" @click="editChatbot(bot)")
        v-list-item-content
          v-list-item-title {{bot.name}}
          v-list-item-subtitle {{bot.kind}} {{bot.server}} {{bot.channel}}
  v-card-actions.px-4
    help-link(path='en/user_manual/groups/integrations/chatbots')
    v-spacer
    action-menu(:actions='addActions' :name="$t('chatbot.add_chatbot')")
</template>
