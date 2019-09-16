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

import { isUndefined, sortBy, filter, find, head, uniq, map, sum, compact, concat, intersection, difference, orderBy } from 'lodash'

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
    tree: []
    myGroups: []
    otherGroups: []
    organizations: []
    unreadCounts: {}
    expandedGroupIds: []

  created: ->
    EventBus.$on 'toggleSidebar', => @open = !@open

    EventBus.$on 'currentComponent', (data) =>
      @group = data.group
      if @group
        @organization = data.group.parentOrSelf()
        if @$route.query.subgroups
          @expandedGroupIds = []
        else
          @expandedGroupIds = [@organization.id]
      else
        @organization = null

    @watchRecords
      collections: ['groups', 'memberships', 'discussions']
      query: (store) => @updateGroups()

    EventBus.$on 'signedIn', (user) => @fetchData()
    @fetchData() if Session.isSignedIn()

  watch:
    organization: 'updateGroups'

    open: (val) ->
      EventBus.$emit("sidebarOpen", val)

  methods:
    fetchData: ->
      Records.users.fetchGroups()
      InboxService.load()

    unreadCountFor: (group, isOpen) ->
      if !isOpen
        (@unreadCounts[group.id] || 0) + sum(compact(group.subgroups().map((g) => @unreadCounts[g.id])))
      else
        @unreadCounts[group.id] || 0

    updateGroups: ->
      @organizations = compact(Session.user().parentGroups().concat(Session.user().orphanParents()))
      @unreadCounts = {}
      Session.user().formalGroups().forEach (group) =>
        @unreadCounts[group.id] = filter(group.discussions(), (discussion) -> discussion.isUnread()).length

      groupAsItem = (group) ->
        id: group.id
        name: group.name
        group: group
        member: Session.user().membershipFor(group)?
        children: if group.subgroups
          orderBy( group.subgroups().map(groupAsItem), ['member', 'name'], ['desc', 'asc']).concat(newSubgroupButton(group))
        else
          []

      initalId = 0
      generateId = -> "id" + (initalId += 1)
      newSubgroupButton = (parentGroup) =>
        if AbilityService.canCreateSubgroups(parentGroup)
          id: generateId()
          name: @$t('common.action.add_subgroup')
          click: => @openStartSubgroupModal(parentGroup)
          icon: 'mdi-plus'
          subgroups: -> []
        else
          []

      @tree = orderBy( @organizations.map((group) -> groupAsItem(group)), ['name'], ['asc'])

    startOrganization: ->
      @canStartGroup() && @openStartGroupModal()

    unreadThreadCount: ->
      InboxService.unreadCount()

    canViewPublicGroups: -> AbilityService.canViewPublicGroups()

    parentGroupLink: (group) ->
      if Session.user().isMemberOf(group)
        @urlFor(group)
      else
        @urlFor(group)+"?subgroups=mine"

    userExpandedGroupIds: (ids) ->
      return unless @group
      @expandedGroupIds = ids if ids.includes(@group.id)
      group = if ids.length == 0 then @organization else @group
      @$router.replace(@groupUrl(group, ids.includes(group.id))).catch((err) => true) if @$route.path == @urlFor(group)

    groupUrl: (group, open) ->
      if (group.isParent() && group.hasSubgroups() && !open)
        @urlFor(group)+'?subgroups=mine'
      else
        @urlFor(group)

  computed:
    user: -> Session.user()
    activeGroup: -> if @group then [@group.id] else []
    logoUrl: -> AppConfig.theme.app_logo_src

    # if we expand or collapse active group, then route changes to that active group with respective subgroups query
    # otherwise, watch route to determine what should render
      # 1. navigate

</script>

<template lang="pug">
v-navigation-drawer.sidenav-left.lmo-no-print(app v-model="open")
  template(v-slot:prepend)
  template(v-slot:append)
    div.text-center
      a(href="/beta") Switch off beta
    v-layout.ma-2(style="width: 50%")
      v-img(:src="logoUrl")
      v-layout(align-center)
        span.ml-4 {{version}}

  v-list-group
    template(v-slot:activator)
      v-list-item-content
        v-list-item-title {{user.name}}
        v-list-item-subtitle {{user.email}}
    user-dropdown
  v-divider
  v-list-item(dense to="/dashboard")
    v-list-item-title(v-t="'sidebar.recent_threads'")
  v-list-item(dense to="/inbox")
    v-list-item-title(v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }")
  v-divider

  //- v-layout(fill-height)
  v-treeview(hoverable :items="tree" :active="activeGroup" @update:open="userExpandedGroupIds" :open="expandedGroupIds" style="width: 100%")
    template(v-slot:append="{item, open}")
      div(v-if="item.click")
        v-icon(v-if="item.icon" @click="item.click") {{item.icon}}
    template(v-slot:prepend="{item, open}")
      //- div(v-if="item.click")
        //- v-icon(v-if="item.icon" @click="item.click") {{item.icon}}
      router-link(v-if="!item.click" :to="groupUrl(item.group, open)")
        group-avatar(:group="item.group"  v-if="item.group.isParent()")
    template(v-slot:label="{item, open}")
      div(v-if="item.click")
        a.body-2.sidebar-item.text-almost-black(text @click="item.click") {{item.name}}
      router-link(v-if="!item.click" :to="groupUrl(item.group, open)")
        span.body-2.sidebar-item.text-almost-black
          span {{item.group.name}}
          span(v-if='unreadCountFor(item.group, open)')
            space
            span ({{unreadCountFor(item.group, open)}})

  v-list-item(@click="startOrganization()" dense)
    v-list-item-title(v-t="'sidebar.start_group'")
    v-list-item-avatar(:size="28")
      v-icon(:size="28" tile) mdi-plus
</template>
<style lang="css">

.sidebar-item {
  display: block;
  width: 100%;
}
</style>
