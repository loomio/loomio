<script lang="js">
import EventBus from '@/shared/services/event_bus';
import ChatbotService from '@/shared/services/chatbot_service';
import Records from '@/shared/services/records';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  props: {
    group: Object
  },

  data() {
    return {
      chatbots: [],
      loading: true,
      addActions: {}
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
    chatbotIcon(bot) {
      return ChatbotService.iconForChatbot(bot);
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
v-card.chatbot-list(:title="$t('chatbot.chat_integrations')")
  template(v-slot:append)
    dismiss-modal-button
  v-card-text
    loading(v-if="loading")
    template(v-if="!loading")
      v-alert(v-if="chatbots.length === 0" type="info" variant="tonal" :icon="false")
        p.mb-3(v-t="'chatbot.no_chat_integrations_yet'")
      v-list-item(v-for="bot in chatbots" :key="bot.id" @click="editChatbot(bot)")
        template(v-slot:prepend)
          common-icon(:name="chatbotIcon(bot)")
        v-list-item-title {{bot.name}}
        v-list-item-subtitle {{bot.kind}} {{bot.server}} {{bot.channel}}
      action-menu(:actions='addActions' :name="$t('chatbot.new_chat_integration')" menu-icon="mdi-plus" list-item)
  v-card-actions
    help-btn(path='en/user_manual/integrations/chatbots')
</template>
