<script lang="js">
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import ChatbotService from '@/shared/services/chatbot_service';
import Records from '@/shared/services/records';
import Flash  from '@/shared/services/flash';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  props: {
    group: Object
  },

  data() {
    return {
      chatbots: [],
      kinds: ['matrix', 'slack', 'discord', 'mattermost', 'teams', 'webex'],
      loading: true,
      addActions: {},
      icons: {
        matrix: 'mdi-matrix',
        slack: 'mdi-slack',
        discord: 'mdi-discord',
        mattermost: 'mdi-chat-processing',
        teams: 'mdi-microsoft-teams',
        webex: 'webex'
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
        EventBus.$emit('openModal', {
          component: 'ChatbotWebhookForm',
          props: {
            chatbot: bot
          }
        });
      } else {
        EventBus.$emit('openModal', {
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
v-card.chatbot-list(:title="$t('chatbot.chatbots')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    loading(v-if="loading")
    template(v-if="!loading")
      v-list-item(v-for="bot in chatbots" :key="bot.id" @click="editChatbot(bot)")
        v-list-item-title {{bot.name}}
        v-list-item-subtitle {{bot.kind}} {{bot.server}} {{bot.channel}}
  v-card-actions
    help-btn(path='en/user_manual/groups/integrations/chatbots')
    v-spacer
    action-menu(:actions='addActions' :name="$t('chatbot.add_chatbot')")
</template>
