<script setup>
import { ref, onMounted, computed } from 'vue';
import AppConfig from '@/shared/services/app_config';
import EventBus from '@/shared/services/event_bus';
import Flash from '@/shared/services/flash';

const subscriptions = ref([]);
const loading = ref(false);
const subscribing = ref(false);
const editingId = ref(null);
const editName = ref('');

const pushSupported = computed(() => {
  return ('Notification' in window) && ('serviceWorker' in navigator);
});

const pushDenied = computed(() => {
  return pushSupported.value && Notification.permission === 'denied';
});

onMounted(() => {
  EventBus.$emit('currentComponent', {
    titleKey: 'push_subscriptions_page.header',
    page: 'pushSubscriptionsPage'
  });
  fetchSubscriptions();
});

async function fetchSubscriptions() {
  loading.value = true;
  try {
    const res = await fetch('/api/v1/push_subscriptions', { credentials: 'same-origin' });
    const data = await res.json();
    subscriptions.value = data.push_subscriptions || [];
  } finally {
    loading.value = false;
  }
}

function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');
  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}

async function subscribe() {
  if (!pushSupported.value) return;
  subscribing.value = true;
  try {
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') {
      subscribing.value = false;
      return;
    }

    const registration = await navigator.serviceWorker.register('/service-worker.js');
    await navigator.serviceWorker.ready;
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: urlBase64ToUint8Array(AppConfig.vapidPublicKey)
    });

    const json = subscription.toJSON();
    await fetch('/api/v1/push_subscriptions', {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        subscription: {
          endpoint: json.endpoint,
          p256dh_key: json.keys.p256dh,
          auth_key: json.keys.auth,
          name: navigator.userAgent.split(/[()]/)[1] || 'This device'
        }
      })
    });
    Flash.success('push_subscriptions_page.subscribed');
    await fetchSubscriptions();
  } catch (e) {
    console.error('Push subscription error:', e);
  } finally {
    subscribing.value = false;
  }
}

function startEditing(sub) {
  editingId.value = sub.id;
  editName.value = sub.name || '';
}

function cancelEditing() {
  editingId.value = null;
  editName.value = '';
}

async function saveName(sub) {
  await fetch(`/api/v1/push_subscriptions/${sub.id}`, {
    method: 'PATCH',
    credentials: 'same-origin',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ subscription: { name: editName.value } })
  });
  Flash.success('push_subscriptions_page.name_updated');
  editingId.value = null;
  editName.value = '';
  await fetchSubscriptions();
}

async function removeSubscription(sub) {
  await fetch(`/api/v1/push_subscriptions/${sub.id}`, {
    method: 'DELETE',
    credentials: 'same-origin'
  });
  Flash.success('push_subscriptions_page.removed');
  await fetchSubscriptions();
}

function truncateEndpoint(endpoint) {
  if (!endpoint) return '';
  return endpoint.length > 60 ? endpoint.substring(0, 60) + '...' : endpoint;
}

function formatDate(dateStr) {
  if (!dateStr) return '';
  return new Date(dateStr).toLocaleDateString();
}
</script>

<template lang="pug">
v-main
  v-container.max-width-1024.px-0.px-sm-3
    v-card
      v-card-title(v-t="'push_subscriptions_page.header'")
      v-card-text
        v-alert.mb-4(v-if="!pushSupported" type="warning" variant="tonal")
          span(v-t="'push_subscriptions_page.notifications_not_supported'")
        v-alert.mb-4(v-if="pushDenied" type="warning" variant="tonal")
          span(v-t="'push_subscriptions_page.notifications_denied'")

        v-btn.mb-4(
          v-if="pushSupported && !pushDenied"
          color="primary"
          :loading="subscribing"
          @click="subscribe"
          prepend-icon="mdi-bell-plus")
          span(v-t="'push_subscriptions_page.subscribe_this_device'")

        v-progress-linear(v-if="loading" indeterminate)

        v-alert.mb-4(v-if="!loading && subscriptions.length === 0" type="info" variant="tonal")
          span(v-t="'push_subscriptions_page.no_subscriptions'")

        v-table(v-if="subscriptions.length > 0")
          thead
            tr
              th(v-t="'push_subscriptions_page.device_name'")
              th Endpoint
              th(v-t="'push_subscriptions_page.subscribed_at'")
              th
          tbody
            tr(v-for="sub in subscriptions" :key="sub.id")
              td
                div(v-if="editingId !== sub.id")
                  span {{ sub.name || '—' }}
                  v-btn.ml-2(size="x-small" variant="text" icon="mdi-pencil" @click="startEditing(sub)")
                div.d-flex.align-center(v-else)
                  v-text-field(
                    v-model="editName"
                    density="compact"
                    hide-details
                    :placeholder="$t('push_subscriptions_page.device_name_placeholder')"
                    variant="outlined"
                    style="max-width: 200px")
                  v-btn.ml-1(size="small" icon="mdi-check" color="primary" @click="saveName(sub)")
                  v-btn.ml-1(size="small" icon="mdi-close" @click="cancelEditing()")
              td.text-medium-emphasis.text-caption {{ truncateEndpoint(sub.endpoint) }}
              td {{ formatDate(sub.created_at) }}
              td
                v-btn(size="small" variant="text" color="error" icon="mdi-delete" @click="removeSubscription(sub)")
</template>
