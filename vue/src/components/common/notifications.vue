<script lang="coffee">
import Records   from '@/shared/services/records'
import AppConfig from '@/shared/services/app_config'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [WatchRecords]

  data: ->
    notifications: []
    unread: []
    unreadCount: 0

  methods:
    viewed: ->
      Records.notifications.viewed()

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
      v-badge(color="accent" v-model="unread.length")
        template(v-slot:badge)
          span.notifications__activity {{unread.length}}
        v-icon mdi-bell
  v-list.notifications__dropdown(avatar v-observe-visibility="{callback: viewed}")
    notification(:notification="notification" v-for="notification in notifications", :key="notification.id")
    div(v-if="notifications.length == 0" v-t="'notifications.no_notifications'")
</template>
