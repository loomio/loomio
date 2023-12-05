<script lang="js">
import EventBus from '@/shared/services/event_bus';
import AppConfig from '@/shared/services/app_config';
import WebhookService from '@/shared/services/webhook_service';
import Records from '@/shared/services/records';
import Flash  from '@/shared/services/flash';
import openModal from '@/shared/helpers/open_modal';

export default {
  props: {
    close: Function,
    group: Object
  },

  data() {
    return {
      webhooks: [],
      loading: true
    };
  },

  mounted() {
    Records.webhooks.fetch({params: {group_id: this.group.id}}).then(() => { return this.loading = false; });
    this.watchRecords({
      collections: ["webhooks"],
      query: records => {
        this.webhooks = records.webhooks.find({groupId: this.group.id});
      }
    });
  },

  methods: {
    addAction(group) {
      return WebhookService.addAction(group);
    },
    webhookActions(webhook) {
      return WebhookService.webhookActions(webhook);
    }
  }
};

</script>
<template lang="pug">
v-card.webhook-list
  v-card-title
    h1.text-h5(tabindex="-1" v-t="'webhook.api_keys'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    p.text--secondary(v-t="'webhook.subtitle'")
    v-alert(type="warning" v-t="'webhook.deprecated'")
    loading(v-if="loading")
    v-list(v-if="!loading")
      v-list-item(v-for="webhook in webhooks" :key="webhook.id")
        v-list-item-content
          v-list-item-title {{webhook.name}}
        v-list-item-action
          action-menu(:actions="webhookActions(webhook)" icon)
  v-card-actions
    help-link(path="en/user_manual/groups/integrations/api")
    v-spacer
    v-btn(color='primary' @click='addAction(group).perform()' v-t="addAction(group).name")
</template>
