<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import RecordLoader   from '@/shared/services/record_loader'
import Session        from '@/shared/services/session'
import EventBus       from '@/shared/services/event_bus'
import {includes, some, compact, intersection, orderBy, slice, debounce} from 'lodash'
import LmoUrlService from '@/shared/services/lmo_url_service'
import { exact, approximate } from '@/shared/helpers/format_time'

export default
  data: ->
    loader: null
    group: Records.groups.fuzzyFind(@$route.params.key)
    searchQuery: null
    subgroups: null
    filter: null
    per: 50
    from: 0
    order: 'created_at desc'
    orders: [
      {text: @$t('members_panel.order_by_name'),  value:'users.name' }
      {text: @$t('members_panel.order_by_created'), value:'created_at' }
      {text: @$t('members_panel.order_by_created_desc'), value:'created_at desc' }
      {text: @$t('members_panel.order_by_admin_desc'), value:'admin desc' }
    ]
    requests: []
    memberships: []

  created: ->
    EventBus.$emit 'currentComponent',
      page: 'groupPage'
      title: @group.name
      group: @group
      search:
        placeholder: @$t('navbar.search_members', name: @group.parentOrSelf().name)

    @loader = new RecordLoader
      collection: 'memberships'
      path: 'autocomplete'
      params:
        q: @search
        group_id: @group.id
        subgroups: @subgroups
        pending: true
        filter: @filter
        per: @per
        from: @from
        order: @order

    @loader.fetchRecords()

    @watchRecords
      collections: ['memberships', 'groups']
      query: @query

  methods:
    exact: exact
    approximate: approximate
    refresh: ->
      @fetch()
      @query()

    query: ->
      chain = Records.memberships.collection.chain()
      switch @subgroups
        when 'mine'
          chain = chain.find(groupId: {$in: intersection(@group.organisationIds(), Session.user().groupIds())})
        when 'all'
          chain = chain.find(groupId: {$in: @group.organisationIds()})
        else
          chain = chain.find(groupId: @group.id)

      if @searchQuery
        chain = chain.where (membership) =>
          some [membership.user().name, membership.user().username], (name) =>
            RegExp("^#{@searchQuery}", "i").test(name) or RegExp(" #{@searchQuery}", "i").test(name)

      switch @filter
        when 'admin'
          chain = chain.find(admin: true)
        when 'pending'
          chain = chain.find(acceptedAt: null)

      records = switch @order
        when 'users.name'
          chain = chain.sort (ma,mb) ->
            a = ma.user().name.toLowerCase()
            b = mb.user().name.toLowerCase()
            switch
              when a == b then 0
              when a > b then 1
              when a < b then -1
          chain.data()
        when 'admin desc'
          chain.simplesort('admin', true).data()
        when 'created_at'
          chain.simplesort('createdAt').data()
        when 'created_at desc'
          chain.simplesort('createdAt', true).data()
        when 'accepted_at desc'
          orderBy(chain.data(), ['acceptedAt', 'desc'])

      @memberships = slice(records, @loader.numRquested)

    fetch: ->
      @loader.fetchRecords
        q: @searchQuery
        from: @from
        order: @order
        filter: @filter
        subgroups: @subgroups

    show: ->
      return false if (@recordCount() == 0 && @pending)
      @initialFetch() if @canView
      @canView

    recordsDisplayed: ->
      _.min [@loader.numRequested, @recordCount()]

    invite: ->
      EventBus.$emit('openModal',
                      component: 'AnnouncementForm',
                      props:
                        announcement: Records.announcements.buildFromModel(@group.targetModel()))

    handleSearchQueryChange: (val) ->
      @$route.query.q = val

  computed:
    canView: ->
      if @pending
        AbilityService.canViewPendingMemberships(@group)
      else
        AbilityService.canViewMemberships(@group)

    membershipRequestsPath: -> LmoUrlService.membershipRequest(@group)
    currentUserIsAdmin: -> Session.user().membershipFor(@group).admin

    showLoadMore: -> !@loader.exhausted

    pollType: ->
      @$t(@group.targetModel().pollTypeKey()) if @group.targetModel().isA('poll')

    totalRecords: ->
      if @pending
        @group.pendingMembershipsCount
      else
        @group.membershipsCount - @group.pendingMembershipsCount

    canAddMembers: ->
      AbilityService.canAddMembers(@group.targetModel().group() || @group) && !@pending

    onlyOneAdminWithMultipleMembers: ->
      (@group.adminMembershipsCount < 2) && ((@group.membershipsCount - @group.adminMembershipsCount) > 0)

  watch:
    '$route.query':
      immediate: true
      handler: (query) ->
        @filter = query.filter
        @subgroups = query.subgroups || 'none' # either: all, mine, none
        @searchQuery = query.q
        @refresh()

    searchQuery: debounce (val, old)->
      @$router.replace(query: {q: val})
    ,
      500

</script>

<template lang="pug">
.members-panel
  //- v-subheader Filters
  //- ul
  //-   li
  //-     router-link(:to="{query: {status: 'all' }}") Admins
  //-   li
  //-     router-link(:to="{query: {status: 'active'}}") Members
  //-   li
  //-     router-link(:to="{query: {status: 'closed'}}") Invited
  v-alert(v-model="onlyOneAdminWithMultipleMembers" color="primary" type="warning")
    template(slot="default")
      span(v-t="'memberships_page.only_one_admin'")

  v-layout.py-2(align-center)
    v-menu
      template(v-slot:activator="{ on }")
        v-btn.mr-2.text-lowercase(v-on="on" text)
          span(v-if="filter == 'admin'" v-t="'members_panel.order_by_admin_desc'")
          span(v-if="filter == 'pending'" v-t="'members_panel.invitations'")
          span(v-if="!filter" v-t="'members_panel.everyone'")
          v-icon mdi-menu-down
      v-list(dense)
        v-list-item(:to="mergeQuery({filter: null})")
          v-list-item-title(v-t="'members_panel.everyone'")
        v-list-item(:to="mergeQuery({filter: 'admin'})")
          v-list-item-title(v-t="'members_panel.order_by_admin_desc'")
        v-list-item(:to="mergeQuery({filter: 'pending'})")
          v-list-item-title(v-t="'members_panel.invitations'")
    v-text-field.mr-2(clearable hide-details solo v-model="searchQuery" :placeholder="$t('navbar.search_members', {name: group.name})" append-icon="mdi-magnify")
    v-btn.membership-card__invite.mr-2(color="primary" v-if='canAddMembers' @click="invite()" v-t="'invitation_form.invite_people'")
    shareable-link-modal(:group="group")
    v-btn.group-page__requests-tab(:to="urlFor(group, 'members/requests')" v-t="'members_panel.requests'")

  v-card(outlined)
    v-list(three-line)
      template(v-for="(membership, index) in memberships")
        v-list-item(:key="membership.id")
          v-list-item-avatar(size='48')
            router-link(:to="urlFor(membership.user())")
              user-avatar(:user='membership.user()' size='48')
          v-list-item-content
            v-list-item-title
              router-link(:to="urlFor(membership.user())") {{ membership.user().name }}
              space
              span.caption(v-if="$route.query.subgroups") {{membership.group().name}}
              space
              span.title.caption {{membership.title}}
              space
              v-chip(v-if="membership.admin" small outlined label v-t="'members_panel.admin'")
            v-list-item-subtitle(v-if="membership.acceptedAt") {{ (membership.user().shortBio || '').replace(/<\/?[^>]+(>|$)/g, "") }}
            v-list-item-subtitle(v-if="!membership.acceptedAt")
              span(v-t="{path: 'members_panel.invited_by_name', args: {name: membership.inviter().name}}")
              //- time-ago(:date="membership.createdAt")
          v-list-item-action
            membership-dropdown(:membership="membership")
        v-divider(v-if="index + 1 < memberships.length" :key="index")
    v-layout(justify-center)
      v-btn.my-2(outlined color='accent' v-if="showLoadMore" :loading="loader.loading" @click="loader.loadMore()" v-t="'common.action.load_more'")

</template>
