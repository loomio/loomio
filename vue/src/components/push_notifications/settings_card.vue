<script setup>
import { computed, onMounted, ref } from 'vue';
import Flash from '@/shared/services/flash';
import RestfulClient from '@/shared/record_store/restful_client';
import PushSubscriptionService from '@/shared/services/push_subscription_service';
import AppConfig from '@/shared/services/app_config';

const client = new RestfulClient('push_subscriptions');
const browserEnabled = ref(false);
const loading = ref(true);
const testing = ref(false);
const subscriptions = ref([]);
const configured = computed(() => AppConfig.webPushEnabled);

const supported = computed(() => PushSubscriptionService.supported());
const denied = computed(() => PushSubscriptionService.permission() === 'denied');

onMounted(refresh);

async function refresh() {
  if (!configured.value) {
    loading.value = false;
    return;
  }
  loading.value = true;
  try {
    browserEnabled.value = await PushSubscriptionService.enabled();
    const data = await client.get('');
    subscriptions.value = data.push_subscriptions || [];
  } finally {
    loading.value = false;
  }
}

async function enable() {
  loading.value = true;
  try {
    await PushSubscriptionService.enable();
    Flash.success('push_notifications.enabled');
    await refresh();
  } catch (error) {
    Flash.error(error.message === 'push_permission_denied'
      ? 'push_notifications.permission_denied'
      : 'push_notifications.not_supported');
  } finally {
    loading.value = false;
  }
}

async function disable() {
  loading.value = true;
  try {
    await PushSubscriptionService.disable();
    Flash.success('push_notifications.disabled');
    await refresh();
  } finally {
    loading.value = false;
  }
}

async function remove(subscription) {
  loading.value = true;
  try {
    await client.destroy(subscription.id);
    Flash.success('push_notifications.device_removed');
    await refresh();
  } finally {
    loading.value = false;
  }
}

async function sendTest() {
  testing.value = true;
  try {
    await PushSubscriptionService.sendTest();
  } catch (_error) {
    Flash.error('common.something_went_wrong');
  } finally {
    testing.value = false;
  }
}
</script>

<template lang="pug">
v-card.mb-4(v-if="configured" :title="$t('push_notifications.title')" :subtitle="$t('push_notifications.subtitle')")
  v-card-text
    v-alert.mb-4(v-if="!supported" type="info" variant="tonal")
      span {{ $t('push_notifications.not_supported') }}
    v-alert.mb-4(v-else-if="denied" type="warning" variant="tonal")
      span {{ $t('push_notifications.permission_denied') }}

    v-btn(
      v-if="supported && !browserEnabled"
      color="primary"
      variant="tonal"
      prepend-icon="mdi-bell-plus-outline"
      :loading="loading"
      @click="enable")
      span {{ $t('push_notifications.enable_device') }}
    v-btn(
      v-else-if="supported"
      variant="tonal"
      prepend-icon="mdi-bell-off-outline"
      :loading="loading"
      @click="disable")
      span {{ $t('push_notifications.disable_device') }}
    v-btn.ml-2(
      v-if="subscriptions.length"
      variant="tonal"
      prepend-icon="mdi-send-outline"
      :disabled="loading"
      :loading="testing"
      @click="sendTest")
      span {{ $t('chatbot.test_connection') }}

    v-list.mt-4(v-if="subscriptions.length" lines="two")
      v-list-subheader {{ $t('push_notifications.devices') }}
      v-list-item(v-for="subscription in subscriptions" :key="subscription.id")
        template(v-slot:prepend)
          common-icon(name="mdi-monitor-cellphone")
        v-list-item-title {{ subscription.name || $t('push_notifications.browser_device') }}
        v-list-item-subtitle {{ subscription.user_agent }}
        template(v-slot:append)
          v-btn(
            icon="mdi-delete-outline"
            variant="text"
            :aria-label="$t('push_notifications.remove_device')"
            @click="remove(subscription)")
</template>
