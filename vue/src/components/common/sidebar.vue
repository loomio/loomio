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

import { isUndefined, sortBy, filter, find, head, uniq, map, compact, concat, intersection, difference } from 'lodash'

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
    subgroups: null

  created: ->
    EventBus.$on 'toggleSidebar', => @open = !@open

    EventBus.$on 'currentComponent', (data) =>
      @subgroups = @$route.query.subgroups
      @group = data.group
      if @group
        @organization = data.group.parentOrSelf()
        Records.groups.fetchByParent(@organization)
      else
        @organization = null
      @updateTree()

    @watchRecords
      collections: ['groups', 'memberships', 'discussions']
      query: (store) => @updateGroups()

    InboxService.load()

  watch:
    organization: 'updateGroups'

    open: (val) ->
      EventBus.$emit("sidebarOpen", val)

  methods:
    updateGroups: ->
      @organizations = Session.user().parentGroups().concat(Session.user().orphanParents())
      if @organization
        @myGroups = intersection Session.user().formalGroups(), @organization.subgroups()
        @otherGroups = difference @organization.subgroups(), Session.user().formalGroups()
        @unreadCounts = {}
        @myGroups.forEach (group) =>
          @unreadCounts[group.id] = filter(group.discussions(), (discussion) -> discussion.isUnread()).length
        @unreadCounts[@organization.id] = filter(@organization.discussions(), (discussion) -> discussion.isUnread()).length

      groupAsItem = (group) ->
        { id: group.id, name: group.name, group: group, children: childrenFor(group).map groupAsItem}

      childrenFor = (group) ->
        intersection(Session.user().formalGroups(), group.subgroups())

      @tree = @organizations.map (group) -> groupAsItem(group)

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

    updateTree: ->
      if @subgroups
        @expandedGroupIds = []
      else
        @expandedGroupIds = [@organization.id]

    userExpandedGroupIds: (ids) ->
      return unless @group
      console.log "userExpandedGroupIds", ids, @groupUrl(@group, @subgroups)
      @expandedGroupIds = ids if ids.includes(@group.id)
      group = if ids.length == 0 then @organization else @group
      @$router.replace(@groupUrl(group, ids.includes(group.id))).catch((err) => true)


    groupUrl: (group, open) ->
      if (group.isParent() && group.hasSubgroups() && !open)
        @urlFor(group)+'?subgroups=mine'
      else
        @urlFor(group)

  computed:
    user: -> Session.user()
    canStartSubGroup: -> @organization && AbilityService.canCreateSubgroups(@organization)
    activeGroup: -> if @group then [@group.id] else []

    # if we expand or collapse active group, then route changes to that active group with respective subgroups query
    # otherwise, watch route to determine what should render
      # 1. navigate

</script>

<template lang="pug">
v-navigation-drawer.sidenav-left(app v-model="open")

  v-layout(fill-height)
    v-treeview(hoverable :items="tree" :active="activeGroup" @update:open="userExpandedGroupIds" :open="expandedGroupIds" style="width: 100%")
      template(v-slot:label="{item, open}")
        router-link(:to="groupUrl(item.group, open)")
          group-avatar(:group="item.group"  v-if="item.group.isParent()")
          span.body-2.ml-2 {{item.group.name}}


    //- v-navigation-drawer(stateless mini-variant mini-variant-width="56" :value="open")
    //-   v-list-item(to="/dashboard")
    //-     v-list-item-avatar(:size="28")
    //-       user-avatar(no-link :user="user")
    //-
    //-   v-tooltip(v-for='group in organizations' :key='group.id' right)
    //-     template(v-slot:activator="{ on }")
    //-       v-list-item(:to='parentGroupLink(group)' dense)
    //-         v-list-item-avatar(size="28px")
    //-           v-avatar(tile size="28px" v-on="on")
    //-             img.sidebar__list-item-group-logo(:src='group.logoUrl()')
    //-     span {{group.name}}
    //-   v-list-item(@click="startOrganization()")
    //-     v-list-item-avatar(:size="28")
    //-       v-icon(:size="28" tile) mdi-plus

    //- v-navigation-drawer(stateless v-if="!organization" :value="open")
    //-   v-list-item(dense)
    //-     v-list-item-content
    //-       v-list-item-title {{user.name}}
    //-       v-list-item-subtitle {{user.email}}
    //-   v-divider
    //-   v-list-item(dense to="/dashboard")
    //-     v-list-item-title(v-t="'sidebar.recent_threads'")
    //-   v-list-item(dense to="/inbox")
    //-     v-list-item-title(v-t="{ path: 'sidebar.unread_threads', args: { count: unreadThreadCount() } }")
    //-   v-divider
    //-   user-dropdown

    //- v-navigation-drawer(stateless v-if="organization" :value="open")
    //-   v-list-item.sidebar__list-item-button--recent(dense exact :to='urlFor(organization)')
    //-     v-list-item-title(v-if="unreadCounts[organization.id]") {{organization.name}} ({{ unreadCounts[organization.id] }})
    //-     v-list-item-title(v-if="!unreadCounts[organization.id]") {{organization.name}}
    //-   div(v-if="myGroups.length > 0")
    //-     v-divider
    //-     v-list-item.sidebar__list-item-button--recent(dense exact :to='urlFor(organization, null, {subgroups: "mine"})')
    //-       v-list-item-title(v-t="'sidebar.my_groups'")
    //-     v-list-item(dense v-for="group in myGroups" :key="group.id" :to="urlFor(group)")
    //-       v-list-item-title(v-if="unreadCounts[group.id]") {{ group.name }} ({{ unreadCounts[group.id] }})
    //-       v-list-item-title(v-if="!unreadCounts[group.id]") {{ group.name }}
    //-   div(v-if="otherGroups.length > 0")
    //-     v-divider
    //-     v-list-item(dense exact :to='urlFor(organization, null, {subgroups: "all"})')
    //-       v-list-item-title(v-t="'sidebar.all_groups'")
    //-     v-list-item(dense v-for="group in otherGroups" :key="group.id" :to="urlFor(group)")
    //-       v-list-item-title {{ group.name }}
    //-       //- v-list-item-title(v-if="unreadCounts[group.id]") {{ group.name }} ({{ unreadCounts[group.id] }})
    //-       //- v-list-item-title(v-if="!unreadCounts[group.id]") {{ group.name }}
    //-       //- v-divider
    //-       //- v-list-item.sidebar__list-item-button--recent(dense exact :to="urlFor(organization, 'subgroups')")
    //-       //-   v-list-item-title(v-t="'sidebar.more_groups'")
    //-
    //-   v-divider
    //-   v-list-item(v-if="canStartSubGroup" dense @click="openStartSubgroupModal(organization)")
    //-     v-list-item-title(v-t="'sidebar.start_subgroup'")
    //-     v-list-item-avatar
    //-       v-icon mdi-plus
    //-
    //-   div(v-if="organization.subscriptionPlan == 'trial'")
    //-     v-divider
    //-     v-subheader(v-t="'plan_names.trial'")
    //-     v-list-item(href="/upgrade" dense)
    //-       v-list-item-title(v-t="'current_plan_button.upgrade'")
    //-       v-list-item-icon
    //-         v-icon(color="primary") mdi-rocket
    //-   template(v-slot:append)
    //-     v-list-item(href="/beta" dense)
    //-       v-list-item-title Loomio 2 - beta {{version}}
</template>
