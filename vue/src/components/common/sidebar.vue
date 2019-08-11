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
    currentParentGroup: null
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
    sortGroups: (groups) -> sortBy groups, 'fullName'
    availableGroups: -> Session.user().formalGroups()

    currentGroup: ->
      return head(@availableGroups()) if @availableGroups().length == 1
      find(@availableGroups(), (g) => g.id == (AppConfig.currentGroup or {}).id) || Records.groups.build()

    unreadThreadCount: ->
      InboxService.unreadCount()

    canViewPublicGroups: -> AbilityService.canViewPublicGroups()
    isCurrentOrganization: (group) ->
      if AppConfig.currentGroup
        AppConfig.currentGroup.parentOrSelf().id == group.id

  computed:
    user: -> Session.user()
    parentGroups: -> Session.user().parentGroups()
    siteName: -> AppConfig.theme.site_name
    logoUrl: -> AppConfig.theme.app_logo_src
    subgroups: -> @currentParentGroup.subgroups()
    canStartSubGroup: -> true

  watch:
    $route: ->
      console.log AppConfig.currentGroup
      @currentParentGroup = AppConfig.currentGroup.parentOrSelf()

</script>

<template lang="pug">
v-navigation-drawer.sidenav-left(app v-model="open")
  //- template(v-slot:prepend)
  //-   v-toolbar(flat)
  //-     img(style="height: 50%" :src="logoUrl" :alt="siteName")
  //-     v-spacer
  //-     v-btn.navbar__sidenav-toggle(icon @click="open = !open")
  //-       v-avatar(tile size="36px")
  //-         v-icon mdi-menu

  v-layout(fill-height)
    v-navigation-drawer(mini-variant mini-variant-width="56")
      v-list-item
        v-list-item-avatar(:size="28")
          user-avatar(:user="user")
      v-list-item(v-for='group in parentGroups' :key='group.id' :to='urlFor(group)' dense)
        v-list-item-avatar(size="28px")
          v-avatar(tile size="28px")
            img.sidebar__list-item-group-logo(:src='group.logoUrl()')
      v-list-item
        v-list-item-avatar(:size="28")
          v-icon(:size="28" tile) mdi-plus

    //- v-list-group.sidebar__user-dropdown()
    //-   template(v-slot:activator)
    //-     v-list-item(dense).pa-0
    //-       v-list-item-icon
    //-         user-avatar(:user="user" :size="24")
    //-       v-list-item-content
    //-         v-list-item-title {{user.name}}
    //-         v-list-item-subtitle {{user.email}}
    //-       //-   v-list-item-title {{user.name}}
    //-   user-dropdown

    v-navigation-drawer(v-if="currentParentGroup")
      v-list-item.sidebar__list-item-button--recent(dense :to='urlFor(currentParentGroup)')
        v-list-item-title {{currentParentGroup.name}}
      v-divider
      v-list-item.sidebar__list-item-button--recent(dense :to='urlFor(currentParentGroup, null, {subgroups: "mine"})')
        v-list-item-title My groups
      v-list-item.sidebar__list-item-button--recent(dense :to='urlFor(currentParentGroup, null, {subgroups: "all"})')
        v-list-item-title All groups
      v-divider
      v-list-item.sidebar__groups(dense v-for="subgroup in currentParentGroup.subgroups()" :to='urlFor(subgroup)' :key="subgroup.id")
        v-list-item-title {{subgroup.name}}
        //- v-list-item(:to='groupUrl(group)' dense)
        //-   //- v-list-item-avatar(size="28px")
        //-   //-   v-avatar(tile size="28px")
        //-   //-     img.sidebar__list-item-group-logo(:src='group.logoUrl()')
        //-   v-list-item-title {{group.name}}
          //- v-list-item-avatar(:size="28")
      v-divider
      v-list-item.sidebar__list-item-button--start-group(dense v-if="canStartSubGroup", @click="openStartSubGroupModal()")
        v-list-item-title(v-t="'sidebar.start_subgroup'")
      v-list-item(dense)
        v-list-item-title
          a(href="/beta") beta {{version}}
</template>
