<script setup lang="js">
import { onMounted, ref } from 'vue';

import EventBus from '@/shared/services/event_bus';
import Records from '@/shared/services/records';
import { useWatchRecords } from '@/composables/useWatchRecords';

const { watchRecords } = useWatchRecords();
const notifications = ref([]);
const unreadIds = ref([]);
const loading = ref(true);

function query() {
  notifications.value = Records.notifications.collection.chain().simplesort('id', true).data();
}

function titleVisible(visible) {
  EventBus.$emit('content-title-visible', visible);
}

watchRecords({
  key: 'notifications-page',
  collections: ['notifications'],
  query
});

onMounted(async () => {
  EventBus.$emit('currentComponent', {
    titleKey: 'notifications.header',
    page: 'notificationsPage',
    group: null
  });
  unreadIds.value = Records.notifications.find({viewed: {$ne: true}}).map(notification => notification.id);
  try {
    await Records.notifications.fetchNotifications();
    unreadIds.value = Records.notifications.find({viewed: {$ne: true}}).map(notification => notification.id);
    await Records.notifications.viewed();
  } finally {
    loading.value = false;
  }
});
</script>

<template lang="pug">
v-main
  v-container.notifications-page.max-width-1024.px-0.px-sm-3
    h1.text-headline-large.my-4(
      tabindex="-1"
      v-intersect="{handler: titleVisible}"
      v-t="'notifications.header'"
    )

    v-card.mb-3(v-if="loading && !notifications.length" variant="flat")
      v-list(lines="two")
        loading-content(:line-count="2" v-for="index in [1, 2, 3]" :key="index")

    v-card.mb-3(v-else variant="flat")
      v-list.notifications-page__list(v-if="notifications.length" lines="two")
        v-list-item.notification(
          v-for="notification in notifications"
          :key="notification.id"
          :class="{'v-list-item--active': unreadIds.includes(notification.id)}"
          :to="notification.href()"
        )
          template(v-slot:prepend)
            user-avatar.mr-3(v-if="notification.actor()" :user="notification.actor()")
          v-list-item-title.notification__content
            span(v-t="{path: notification.translationPath(), args: notification.args()}")
            space
            mid-dot
            space
            time-ago(:date="notification.createdAt")
      v-card-text(v-else v-t="'notifications.no_notifications'")
</template>

<style>
.notifications-page__list .notification__content {
  white-space: initial;
}
</style>
