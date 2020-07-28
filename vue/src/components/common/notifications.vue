<script lang="coffee">
import Records   from '@/shared/services/records'
import AppConfig from '@/shared/services/app_config'
import {compact, orderBy} from 'lodash-es'

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
        @unread = Records.notifications.find(viewed: { $ne: true })
        @unreadIds = @unread.map (n) -> n.id
        Records.notifications.viewed()

  created: ->
    Records.notifications.fetchNotifications()
    @watchRecords
      collections: ['notifications']
      query: (store) =>
        @notifications = store.notifications.collection.chain().simplesort('id', true).data()
        @unread = store.notifications.find(viewed: { $ne: true })
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

  v-sheet.notifications__dropdown
    v-list(v-if="notifications.length > 0" dense)
      v-list-item.notification(:class="{'v-list-item--active': unreadIds.includes(n.id)}" v-for="n in notifications" :key="n.id" :to="n.href()")
        v-list-item-avatar
          user-avatar(v-if="n.actor()" :user="n.actor()" size="thirtysix")
        v-list-item-content
          v-list-item-title.notification__content.body-2
            span(v-html="$t(n.path(), n.args())")
            space
            span(aria-hidden='true') ·
            space
            time-ago(:date="n.createdAt")
    div(v-if="notifications.length == 0" v-t="'notifications.no_notifications'")
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
