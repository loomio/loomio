<script setup>
import { ref } from 'vue';
import Records from '@/shared/services/records';

function userFor(notification) { return Records.users.find(notification.user_id); }

const props = defineProps({
  close: Function,
  model: { type: Object, required: true }
});

const historyData = ref([]);
const historyLoading = ref(true);
const historyError = ref(false);
const allowViewed = ref(false);

Records.fetch({
  path: 'announcements/history',
  params: props.model.namedId()
}).then(data => {
  historyData.value = data.data || [];
  allowViewed.value = data.allow_viewed;
  const userIds = [];
  historyData.value.forEach(event => {
    if (event.author_id) userIds.push(event.author_id);
    event.notifications.forEach(n => { if (n.user_id) userIds.push(n.user_id); });
  });
  Records.users.fetchAnyMissingById(userIds);
}).catch(() => {
  historyError.value = true;
}).finally(() => {
  historyLoading.value = false;
});

const modelKind = props.model.constructor.singular;
</script>

<template lang="pug">
v-card(:title="$t('announcement.' + modelKind + '_notification_history')")
  template(v-slot:append)
    dismiss-modal-button
  .d-flex.justify-center.pa-8(v-if="historyLoading")
    v-progress-circular(color="primary" indeterminate)
  v-card-text.text-body-2(v-else)
    p(v-if="historyError" v-t="'announcement.history_error'")
    p(v-else-if="historyData.length == 0" v-t="'announcement.no_notifications_sent'")
    template(v-else)
      div(v-for="event in historyData" :key="event.id")
        h4.mt-4.mb-2
          time-ago(:date="event.created_at")
          mid-dot
          span(v-t="{ path: 'announcement.'+event.kind, args: { name: event.author_name, length: event.notifications.length } }")
        ul(style="list-style-type: none; padding-left: 0")
          li.d-flex.align-center.ga-2.py-1(v-for="notification in event.notifications" :key="notification.id")
            user-avatar(v-if="userFor(notification)" :user="userFor(notification)" :size="28" no-link)
            span {{notification.to}}
            v-chip(v-if="allowViewed && notification.viewed" size="x-small" color="success" variant="tonal")
              span(v-t="'common.read'")
            v-chip(v-else-if="allowViewed" size="x-small" color="warning" variant="tonal")
              span(v-t="'common.unread'")
</template>
