<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import InboxService   from '@/shared/services/inbox_service'
import GroupModalMixin from '@/mixins/group_modal.coffee'
import DiscussionModalMixin from '@/mixins/discussion_modal.coffee'
import WatchRecords from '@/mixins/watch_records'

import { isUndefined, sortBy, filter, find, head, uniq, map, compact, concat } from 'lodash'

export default
  mixins: [
    GroupModalMixin,
    DiscussionModalMixin,
    WatchRecords
  ]

  data: ->
    groups: []
    open: null

  created: ->
    EventBus.$on 'toggleSidebar', => @open = !@open

    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) =>
        groups = Session.user().formalGroups()
        parentGroups = uniq compact concat(groups, map(groups, (group) -> group.parent()))
        @groups = sortBy parentGroups, 'fullName'

    InboxService.load()

  watch:
    open: (val) ->
      EventBus.$emit("sidebarOpen", val)

  methods:
    availableGroups: -> Session.user().formalGroups()

    currentGroup: ->
      return head(@availableGroups()) if @availableGroups().length == 1
      find(@availableGroups(), (g) => g.id == (AppConfig.currentGroup or {}).id) || Records.groups.build()

    groupUrl: (group) ->
      LmoUrlService.group(group)

    unreadThreadCount: ->
      InboxService.unreadCount()

    canViewPublicGroups: -> AbilityService.canViewPublicGroups()
  computed:
    user: -> Session.user()
    siteName: -> AppConfig.theme.site_name
    logoUrl: -> AppConfig.theme.app_logo_src

</script>

<template lang="pug">
v-navigation-drawer.lmo-no-print.sidenav-left(app width="250" v-model="open")
  v-toolbar
    img(style="height: 50%" :src="logoUrl" :alt="siteName")
    v-spacer
    v-btn.navbar__sidenav-toggle(icon v-if="!sidebarOpen" @click="open = !open")
      v-avatar(tile size="36px")
        v-icon mdi-menu
  v-expansion-panel
    v-expansion-panel-content
      template(v-slot:header)
        v-layout
          user-avatar.mr-2(:user="user" size="medium")
          v-flex
            .body-1 {{user.name}}
            .body-1 @{{user.username}}
      user-dropdown

    v-expansion-panel-content
      template(v-slot:header)
        v-subheader(v-t="'sidebar.threads'")
      v-list
        v-list-tile.sidebar__list-item-button--recent(to='/dashboard')
          v-list-tile-action
            v-icon mdi-forum
          v-list-tile-content
            v-list-tile-title(v-t="'sidebar.recent_threads'")
        v-list-tile.sidebar__list-item-button--unread(to='/inbox')
          v-list-tile-action
            v-icon mdi-inbox
          v-list-tile-content
            v-list-tile-title(v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }")
        v-list-tile.sidebar__list-item-button--muted(to='/dashboard/show_muted')
          v-list-tile-action
            v-icon mdi-volume-mute
          v-list-tile-content
            v-list-tile-title(v-t="'sidebar.muted_threads'")
        v-list-tile.sidebar__list-item-button--decisions(to='/polls')
          v-list-tile-action
            v-icon mdi-thumbs-up-down
          v-list-tile-content
            v-list-tile-title(v-t="'common.decisions'")
        v-list-tile.sidebar__list-item-button--start-thread(v-if='canStartThreads()', @click='openStartDiscussionModal(currentGroup())')
          v-list-tile-action
            v-icon mdi-plus
          v-list-tile-content
            v-list-tile-title(v-t="'sidebar.start_thread'")
    v-expansion-panel-content
      template(v-slot:header)
        v-subheader(v-t="'common.groups'")

      v-list
        div.sidebar__groups(v-for='group in groups', :key='group.id')
          v-list-tile(:to='groupUrl(group)', v-if='group.isParent()')
            v-list-tile-action
              img.md-avatar.lmo-box--tiny.sidebar__list-item-group-logo(:src='group.logoUrl()')
            v-list-tile-content
              v-list-tile-title {{group.name}}
          v-list-tile(:to='groupUrl(group)', v-if='!group.isParent()')
            v-list-tile-action
              img.md-avatar.lmo-box--tiny.sidebar__list-item-group-logo(:src='group.logoUrl()')
            v-list-tile-content
              v-list-tile-title {{group.name}}
        v-list-tile.sidebar__list-item-button--start-group(v-if="canStartGroup()", @click="openStartGroupModal()")
          v-list-tile-action
            v-icon mdi-plus
          v-list-tile-content
            span(v-t="'sidebar.start_group'")
</template>
