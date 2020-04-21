<script lang="coffee">
import Records   from '@/shared/services/records'
import AppConfig from '@/shared/services/app_config'
import {compact, orderBy} from 'lodash'

export default
  data: ->
    notifications: []
    unread: []
    unreadCount: 0
    unreadIds: []
    open: false

  watch:
    open: (newVal, oldVal) ->
      if oldVal && !newVal
        @unreadIds = []
        @unreadCount = 0
      if newVal && !oldVal
        @unread = Records.notifications.find(kind: {$in: AppConfig.notifications.kinds}, viewed: { $ne: true })
        @unreadIds = @unread.map (n) -> n.id
        Records.notifications.viewed()

  created: ->
    Records.notifications.fetchNotifications()
    @watchRecords
      collections: ['notifications']
      query: (store) =>
        @notifications = orderBy(store.notifications.find(kind: {$in: AppConfig.notifications.kinds}), ['createdAt'], ['desc'])
        @unread = store.notifications.find(kind: {$in: AppConfig.notifications.kinds}, viewed: { $ne: true })
        @unreadCount = @unreadCount

</script>
<template lang="pug">
v-menu.notifications(offset-y bottom v-model="open")
  template(v-slot:activator="{on}")
    v-btn.notifications__button(icon v-on="on" :aria-label="$t('navbar.notifications')")
      v-badge(color="accent" v-model="unread.length")
        template(v-slot:badge)
          span.notifications__activity {{unread.length}}
        v-icon mdi-bell
  v-sheet.notifications__dropdown.py-2
    div(v-if ="notifications.length > 0" v-for="notification in notifications", :key="notification.id")
      notification(:notification="notification", :unread="unreadIds.includes(notification.id)")
    v-layout.align-center.justify-center(v-if="notifications.length == 0")
      span.py-3.px-3(v-t="'notifications.no_notifications'")
</template>

<style lang="sass">
.notifications__dropdown
  max-width: 512px
  overflow-y: scroll
  max-height: 600px
</style>
