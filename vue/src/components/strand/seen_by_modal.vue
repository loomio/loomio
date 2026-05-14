<script setup>
import { ref } from 'vue';
import Records from '@/shared/services/records';
import { orderBy } from 'lodash-es';

function userFor(reader) { return Records.users.find(reader.user_id); }

const { topic } = defineProps({ topic: Object });

const tab = ref('seen_by');

const seenByData = ref([]);
const seenByLoading = ref(true);
const seenByError = ref(false);

const notifData = ref([]);
const notifLoading = ref(true);
const notifError = ref(false);
const allowViewed = ref(false);

Records.fetch({path: `topics/${topic.id}/history`}).then(data => {
  seenByData.value = orderBy(data, ['last_read_at'], ['desc']) || [];
  Records.users.fetchAnyMissingById(seenByData.value.map(r => r.user_id));
}).catch(() => {
  seenByError.value = true;
}).finally(() => {
  seenByLoading.value = false;
});

Records.fetch({path: 'announcements/history', params: {topic_id: topic.id}}).then(data => {
  notifData.value = data.data || [];
  allowViewed.value = data.allow_viewed;
  const userIds = [];
  notifData.value.forEach(event => {
    if (event.author_id) userIds.push(event.author_id);
    event.notifications.forEach(n => { if (n.user_id) userIds.push(n.user_id); });
  });
  Records.users.fetchAnyMissingById(userIds);
}).catch(() => {
  notifError.value = true;
}).finally(() => {
  notifLoading.value = false;
});
</script>

<template lang="pug">
v-card(:title="$t('discussion_last_seen_by.thread_engagement')")
  template(v-slot:append)
    dismiss-modal-button
  v-tabs(v-model="tab" color="primary" variant="outlined" grow)
    v-tab(value="seen_by")
      span(v-t="'discussion_last_seen_by.title'")
    v-tab(value="notifications")
      span(v-t="'announcement.notification_history'")
  v-window(v-model="tab")
    v-window-item(value="seen_by")
      .d-flex.justify-center.pa-8(v-if="seenByLoading")
        v-progress-circular(color="primary" indeterminate)
      v-card-text.text-body-2(v-else)
        p(v-if="seenByError" v-t="'announcement.history_error'")
        p(v-else-if="seenByData.length == 0" v-t="'discussion_last_seen_by.no_one'")
        div.d-flex.align-center.ga-2.py-1(v-else v-for="reader in seenByData" :key="reader.reader_id")
          user-avatar(v-if="userFor(reader)" :user="userFor(reader)" :size="28" no-link)
          span {{reader.user_name}}
          mid-dot
          time-ago.text-medium-emphasis(:date="reader.last_read_at")
    v-window-item(value="notifications")
      .d-flex.justify-center.pa-8(v-if="notifLoading")
        v-progress-circular(color="primary" indeterminate)
      v-card-text.text-body-2(v-else)
        p(v-if="notifError" v-t="'announcement.history_error'")
        p(v-else-if="notifData.length == 0" v-t="'announcement.no_notifications_sent'")
        template(v-else)
          div(v-for="event in notifData" :key="event.id")
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
