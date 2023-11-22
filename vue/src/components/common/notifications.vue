<script lang="js">
import Records   from '@/shared/services/records';
import AppConfig from '@/shared/services/app_config';

export default {
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
      if (this.open) {
        this.unread = Records.notifications.find({viewed: { $ne: true }});
        this.unreadIds = this.unread.map(n => n.id);
        Records.notifications.viewed();
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
<template>

<v-menu class="notifications" v-model="open" offset-y="offset-y" bottom="bottom">
  <template v-slot:activator="{attrs}">
    <v-btn class="notifications__button" icon="icon" v-bind="attrs" :title="$t('navbar.notifications')" @click="clicked">
      <v-badge color="primary" v-model="unread.length">
        <template v-slot:badge="v-slot:badge"><span class="notifications__activity">{{unread.length}}</span></template>
        <common-icon name="mdi-bell"></common-icon>
      </v-badge>
    </v-btn>
  </template>
  <v-sheet class="notifications__dropdown">
    <v-list v-if="notifications.length > 0" dense="dense">
      <v-list-item class="notification" :class="{'v-list-item--active': unreadIds.includes(n.id)}" v-for="n in notifications" :key="n.id" :to="n.href()">
        <v-list-item-avatar>
          <user-avatar v-if="n.actor()" :user="n.actor()" :size="36"></user-avatar>
        </v-list-item-avatar>
        <v-list-item-content>
          <v-list-item-title class="notification__content"><span v-t="{path: 'notifications.with_title.'+n.kind, args: n.args()}"></span>
            <space></space>
            <mid-dot></mid-dot>
            <space></space>
            <time-ago :date="n.createdAt"></time-ago>
          </v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>
    <template v-if="notifications.length == 0">
      <v-list-item class="notification" v-t="'notifications.no_notifications'"></v-list-item>
    </template>
  </v-sheet>
</v-menu>
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
