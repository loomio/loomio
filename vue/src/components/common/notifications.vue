<script lang="coffee">
import Records   from '@/shared/services/records'
import AppConfig from '@/shared/services/app_config'

export default
  created: ->
    @notificationsView = Records.notifications.collection.addDynamicView("notifications")
                               .applyFind(kind: { $in: AppConfig.notifications.kinds })

    @unreadView =        Records.notifications.collection.addDynamicView("unread")
                               .applyFind(kind: { $in: AppConfig.notifications.kinds })
                               .applyFind(viewed: { $ne: true })
  computed:
    notifications: -> @notificationsView.data()
    count: -> @notificationsView.data().length
    unreadCount: -> @unreadView.data().length
    hasUnread: -> @unreadCount > 0

</script>
<template lang="pug">
v-menu.notifications(offset-y lazy)
  v-btn.notifications__button(icon slot="activator", :aria-label="$t('navbar.notifications')")
    v-icon(v-if="!hasUnread") mdi-bell
    v-icon(v-if="hasUnread") mdi-bell-ring
    span.badge.notifications__activity(v-if="hasUnread") {{unreadCount}}
  v-list.notifications__dropdown(avatar)
    div(v-for="notification in notifications", :key="notification.id")
      notification(:notification="notification")
    div(v-if="notifications.length == 0" v-t="'notifications.no_notifications'")

</template>
