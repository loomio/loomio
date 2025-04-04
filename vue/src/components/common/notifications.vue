<script lang="js">
import Records   from '@/shared/services/records';
import AppConfig from '@/shared/services/app_config';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],
  data() {
    return {
      notifications: [],
      unread: [],
      unreadCount: 0,
      unreadIds: [],
      open: false
    };
  },

  methods: {
    clicked() {
      this.open = !this.open;

    }
  },

  watch: {
    open(val) {
      if (val) {
        this.unread = Records.notifications.find({viewed: { $ne: true }});
        this.unreadIds = this.unread.map(n => n.id);
        Records.notifications.viewed();
        Records.notifications.fetchNotifications();
      } else {
        this.unreadIds = [];
        this.unreadCount = 0;
      }
    }
  },

  created() {
    Records.notifications.fetchNotifications();
    this.watchRecords({
      collections: ['notifications'],
      query: store => {
        this.notifications = store.notifications.collection.chain().simplesort('id', true).data();
        this.unread = store.notifications.find({viewed: { $ne: true }});
        this.unreadCount = this.unreadCount;
      }
    });
  }
};

</script>
<template lang="pug">
v-menu.notifications(location="bottom" v-model="open")
  template(v-slot:activator="{ props }")
    v-btn.notifications__button(icon v-bind="props" :title="$t('navbar.notifications')")
      v-badge(color="primary" :content="unread.length" v-if="unread.length")
        common-icon(name="mdi-bell")
      common-icon(v-else name="mdi-bell")

  v-list.notifications__dropdown(v-if="notifications.length > 0" lines="two")
    v-list-item.notification(:class="{'v-list-item--active': unreadIds.includes(n.id)}" v-for="n in notifications" :key="n.id" :to="n.href()")
      template(v-slot:prepend)
        user-avatar.mr-3(v-if="n.actor()" :user="n.actor()")
      v-list-item-title.notification__content
        span(v-t="{path: 'notifications.with_title.'+n.kind, args: n.args()}")
        space
        mid-dot
        space
        time-ago(:date="n.createdAt")
  v-sheet.notifications__dropdown(v-else)
    v-list-item.notification(v-t="'notifications.no_notifications'")
</template>

<style lang="sass">
.notifications__dropdown
  max-width: 512px
  overflow-y: scroll
  max-height: 600px

.notification__content
  white-space: initial
  -webkit-line-clamp: 2
  -webkit-box-orient: vertical
  display: -webkit-box
</style>
