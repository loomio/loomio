<script lang="coffee">
import Records   from '@/shared/services/records'
import AppConfig from '@/shared/services/app_config'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [WatchRecords]
  created: ->
    @watchRecords
      collections: ['notifications']
      query: (store) =>
        @notifications = store.notifications.find(kind: {$in: AppConfig.notifications.kinds})
        @unread = store.notifications.find(kind: {$in: AppConfig.notifications.kinds}, viewed: { $ne: true })
        @unreadCount = @unread.length

</script>
<template lang="pug">
v-menu.notifications(offset-y bottom)
  template(v-slot:activator="{on}")
    v-btn.notifications__button(icon v-on="on" :aria-label="$t('navbar.notifications')")
      v-icon(v-if="!unread.length") mdi-bell
      v-icon(v-if="unread.length") mdi-bell-ring
      span.badge.notifications__activity(v-if="unread.length") {{unread.length}}
  v-list.notifications__dropdown(avatar)
    notification(:notification="notification" v-for="notification in notifications", :key="notification.id")
    div(v-if="notifications.length == 0" v-t="'notifications.no_notifications'")
</template>
