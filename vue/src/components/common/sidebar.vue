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
    organization: null
    open: null
    group: null
    version: AppConfig.version.split('.').slice(-1)[0]

  created: ->
    EventBus.$on 'toggleSidebar', => @open = !@open

    EventBus.$on 'currentComponent', (data) =>
      @group = data.group
      @organization = data.group.parentOrSelf()

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

    '$route': ->
      console.log '$route', @$route


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
    subgroups: -> @organization.subgroups()
    canStartSubGroup: -> true

</script>

<template lang="pug">
v-navigation-drawer.sidenav-left(app v-model="open")

  v-layout(fill-height)
    v-navigation-drawer(stateless mini-variant mini-variant-width="56" :value="open")
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

    v-navigation-drawer(stateless v-if="organization" :value="open")
      v-list-item.sidebar__list-item-button--recent(dense exact :to='urlFor(organization)')
        v-list-item-title {{organization.name}}
      v-divider
      v-list-item.sidebar__list-item-button--recent(dense exact :to='urlFor(organization, null, {subgroups: "mine"})')
        v-list-item-title My groups
      v-list-item.sidebar__list-item-button--recent(dense exact :to='urlFor(organization, null, {subgroups: "all"})')
        v-list-item-title All groups
      v-divider
      v-list-item.sidebar__groups(dense v-for="subgroup in organization.subgroups()" :to='urlFor(subgroup)' :key="subgroup.id")
        v-list-item-title {{subgroup.name}}

      v-divider
      v-list-item.sidebar__list-item-button--start-group(dense v-if="canStartSubGroup", @click="openStartSubGroupModal()")
        v-list-item-title(v-t="'sidebar.start_subgroup'")
      v-list-item(dense)
        v-list-item-title
          a(href="/beta") beta {{version}}
</template>
