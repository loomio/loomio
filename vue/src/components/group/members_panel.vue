<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import RecordLoader   from '@/shared/services/record_loader'
import Session        from '@/shared/services/session'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import {includes, some, compact, intersection, orderBy, slice} from 'lodash'
import LmoUrlService from '@/shared/services/lmo_url_service'
import { exact, approximate } from '@/shared/helpers/format_time'

export default
  mixins: [AnnouncementModalMixin]

  data: ->
    loader: null
    group: Records.groups.fuzzyFind(@$route.params.key)
    search: @$route.query.q || ''
    subgroups: @$route.query.subgroups || 'none'
    per: 50
    from: 0
    tab: 'directory'
    order: 'accepted_at desc'
    orders: [
      {text: @$t('members_panel.order_by_name'),  value:'users.name' }
      {text: @$t('members_panel.order_by_created'), value:'created_at' }
      {text: @$t('members_panel.order_by_created_desc'), value:'created_at desc' }
      {text: @$t('members_panel.order_by_admin_desc'), value:'admin desc' }
    ]


  created: ->
    if AbilityService.canManageMembershipRequests(@group)
      Records.membershipRequests.fetchPendingByGroup(@group.key, per: 100)
      Records.membershipRequests.fetchPreviousByGroup(@group.key, per: 100)
      @watchRecords
        collections: ['membershipRequests']
        query: (store) =>
          @requests = orderBy @group.membershipRequests(), ['respondedAt', 'desc'], ['createdAt', 'desc']

    @loader = new RecordLoader
      collection: 'memberships'
      path: 'autocomplete'
      params:
        q: @search
        group_id: @group.id
        subgroups: @subgroups
        pending: true
        per: @per
        from: @from
        order: @order

    @loader.fetchRecords()

    @watchRecords
      collections: ['memberships']
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

      if @search
        chain = chain.where (membership) =>
          some [membership.user().name, membership.user().username], (name) =>
            RegExp("^#{@search}", "i").test(name) or RegExp(" #{@search}", "i").test(name)


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
          console.log orderBy(chain.data(), ['acceptedAt', 'desc'])
          orderBy(chain.data(), ['acceptedAt', 'desc'])

      @memberships = slice(records, @loader.numRquested)

    fetch: ->
      @loader.fetchRecords
        q: @search
        from: @from
        order: @order
        subgroups: @subgroups

    show: ->
      return false if (@recordCount() == 0 && @pending)
      @initialFetch() if @canView()
      @canView()

    canView: ->
      if @pending
        AbilityService.canViewPendingMemberships(@group)
      else
        AbilityService.canViewMemberships(@group)

    canAddMembers: ->
      AbilityService.canAddMembers(@group.targetModel().group() || @group) && !@pending

    recordsDisplayed: ->
      _.min [@loader.numRequested, @recordCount()]

    invite: ->
      @openAnnouncementModal(Records.announcements.buildFromModel(@group.targetModel()))

    cardTitle: ->
      if @pending
        'membership_card.invitations'
      else
        "membership_card.#{@group.targetModel().constructor.singular}_members"

    # componentType: (membership) ->
    #   if membership.acceptedAt
    #     'router-link'
    #   else
    #     'div'

  computed:
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

  watch:
    '$route.query.subgroups': (val) ->
      if ['mine', 'all'].includes(val)
        @subgroups = val
      else
        @subgroups = 'none'

    '$route.query.q': (val) ->
      @search = val
      @refresh()

</script>

<template lang="pug">
v-card.members-panel
  v-tabs(fixed-tabs v-model="tab")
    v-tab(key="direcory") Directory
    v-tab(key="invitations") Invitations
    v-tab(key="requests") Requests
  v-tabs-items(v-model="tab")
    v-tab-item(key="directory")
      v-toolbar(flat align-center)
        v-btn.membership-card__invite.mr-2(color="primary" v-if='canAddMembers()' @click="invite()" v-t="'common.action.invite'")
        v-btn.membership-requests-link(outlined color="accent" :to="membershipRequestsPath" v-t="'members_panel.view_requests'")
        v-spacer
        v-progress-linear(color="accent" indeterminate :active="loader.loading" absolute bottom)
      v-divider

      v-list(two-line)
        template(v-for="(membership, index) in memberships")
          v-list-item
            v-icon(v-if="membership.admin") mdi-star
            v-list-item-avatar(size='64')
              router-link(:to="urlFor(membership.user())")
                user-avatar(:user='membership.user()' size='64')
            v-list-item-content
              v-list-item-title
                router-link(:to="urlFor(membership.user())") {{ membership.user().name }}
                space
                span.caption {{membership.title}}
              v-list-item-subtitle {{ membership.user().shortBio }}
            v-list-item-action
              v-list-item-action-text {{ approximate(membership.createdAt) }}
              membership-dropdown(:membership="membership")
              //- v-menu(offset-y)
              //-   template(v-slot:activator="{on}")
              //-     v-btn(icon v-on="on")
              //-       v-icon mdi-dots-vertical
              //-   v-list
              //-     v-list-item Contact
          v-divider(v-if="index + 1 < memberships.length" :key="index")

    v-tab-item(key="invitations")
      v-simple-table
        thead
          tr
            th Photo
            th Name
            th Email
            th Accepted
            td(v-if="subgroups != 'none'") Subgroup
            th Invited by
            th Sent
        tbody
          tr(v-for="(membership, index) in memberships")
            td
              user-avatar.mr-4(:user='membership.user()', size='forty')
            td.members-panel__name
              v-layout(align-center)
                router-link(:to="urlFor(membership.user())") {{membership.user().name}}
            td.members-panel__email {{membership.user().email}}
            td.members-panel__accepted {{membership.acceptedAt ? approximate(membership.acceptedAt) : '' }}
            td(v-if="subgroups != 'none'") {{membership.group().name}}
            td {{membership.inviter() && membership.inviter().name}}
            td
              timeAgo(:date="membership.createdAt")
    v-tab-item(key="requests")
      v-list(two-line)
        membership-request(v-for="request in requests" :request="request" :key="request.id")

  v-layout(align-center)
    //- span(v-if="!includeSubgroups" v-t="{path: 'members_panel.loaded_of_total', args: {loaded: loader.numLoaded, total: totalRecords}}")
    v-btn(v-if="showLoadMore" :loading="loader.loading" @click="loader.loadMore()" v-t="'common.action.load_more'")

</template>
