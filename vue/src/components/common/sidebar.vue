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
    parentGroups: []
    open: null
    version: AppConfig.version.split('.').slice(-1)[0]

  created: ->
    EventBus.$on 'toggleSidebar', => @open = !@open

    @watchRecords
      collections: ['groups', 'memberships']
      query: (store) =>
        @groups = Session.user().parentGroups().concat(Session.user().orphanSubgroups()).filter (g) -> g.type == "FormalGroup"
        # @groups = Session.user().formalGroups().filter (group) ->
        #   group.isParent() or !Session.user().isMemberOf(group.parent())
        # @ = uniq compact concat(groups, map(groups, (group) -> group.parent()))
        @groups = sortBy @groups, 'fullName'

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
v-navigation-drawer.sidenav-left(app v-model="open")
  template(v-slot:prepend)
    v-toolbar
      img(style="height: 50%" :src="logoUrl" :alt="siteName")
      v-spacer
      v-btn.navbar__sidenav-toggle(icon @click="open = !open")
        v-avatar(tile size="36px")
          v-icon mdi-menu
  v-list-group.sidebar__user-dropdown()
    template(v-slot:activator)
      v-list-item(dense).pa-0
        v-list-item-icon
          user-avatar(:user="user" :size="24")
        v-list-item-content
          v-list-item-title {{user.name}}
          v-list-item-subtitle {{user.email}}
        //-   v-list-item-title {{user.name}}
    user-dropdown
  v-divider
  //- v-list(nav)
  v-list-item.sidebar__list-item-button--recent(dense to='/dashboard')
    v-list-item-icon
      v-icon mdi-forum
    v-list-item-title(v-t="'sidebar.recent_threads'")
  v-list-item.sidebar__list-item-button--unread(dense to='/inbox')
    v-list-item-icon
      v-icon mdi-inbox
    v-list-item-title(v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }")
    //- v-list-item.sidebar__list-item-button--muted(to='/dashboard/show_muted')
    //-   v-list-item-avatar(:size="20")
    //-     v-icon(:size="20") mdi-volume-mute
    //-   v-list-item-title(v-t="'sidebar.muted_threads'")
    //- v-list-item.sidebar__list-item-button--decisions(to='/polls')
    //-   v-list-item-avatar(:size="20")
    //-     v-icon(:size="20") mdi-thumbs-up-down
    //-   v-list-item-title(v-t="'common.decisions'")
  v-list-item.sidebar__list-item-button--start-thread(dense v-if='canStartThreads()', @click='openStartDiscussionModal(currentGroup())')
    v-list-item-icon
      v-icon mdi-plus
    v-list-item-title(v-t="'sidebar.start_thread'")
  v-divider.sidebar__divider
  div.sidebar__groups(v-for='group in groups', :key='group.id')
    v-list-item(:to='groupUrl(group)' dense)
      v-list-item-avatar(:size="28" tile)
        v-avatar(tile size="28px")
          img.sidebar__list-item-group-logo(:src='group.logoUrl()')
      v-list-item-title {{group.name}}
    v-list-item(v-for="subgroup in group.subgroups()" dense :to='groupUrl(subgroup)' :key="subgroup.id")
      v-list-item-avatar(:size="28")
      v-list-item-title {{subgroup.name}}
  v-list-item.sidebar__list-item-button--start-group(v-if="canStartGroup()", @click="openStartGroupModal()")
    v-list-item-action
      v-icon mdi-plus
    v-list-item-content
      span(v-t="'sidebar.start_group'")
  v-list-item
    v-list-item-title
      a(href="/beta") beta {{version}}
</template>

<style lang="scss">
.sidebar__user-dropdown .v-list-group__header {
  // padding: 0;
}
</style>
