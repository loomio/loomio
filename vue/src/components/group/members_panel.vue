<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import RecordLoader   from '@/shared/services/record_loader'
import Session        from '@/shared/services/session'
import EventBus       from '@/shared/services/event_bus'
import {includes, some, compact, intersection, orderBy, slice, debounce, min, escapeRegExp, map} from 'lodash'
import LmoUrlService from '@/shared/services/lmo_url_service'
import { exact, approximate } from '@/shared/helpers/format_time'

export default
  data: ->
    loader: null
    group: null
    per: 25
    order: 'created_at desc'
    orders: [
      {text: @$t('members_panel.order_by_name'),  value:'users.name' }
      {text: @$t('members_panel.order_by_created'), value:'memberships.created_at' }
      {text: @$t('members_panel.order_by_created_desc'), value:'memberships.created_at desc' }
      {text: @$t('members_panel.order_by_admin_desc'), value:'admin desc' }
    ]
    memberships: []

  created: ->
    @onQueryInput = debounce (val) =>
      @$router.replace(@mergeQuery(q: val))
    , 500

    Records.groups.findOrFetch(@$route.params.key).then (group) =>
      @group = group

      EventBus.$emit 'currentComponent',
        page: 'groupPage'
        title: @group.name
        group: @group
        search:
          placeholder: @$t('navbar.search_members', name: @group.parentOrSelf().name)

      @loader = new RecordLoader
        collection: 'memberships'
        params:
          exclude_types: 'group'
          group_id: @group.id
          per: @per
          order: @order
          subgroups: 'all'

      @watchRecords
        collections: ['memberships', 'groups']
        query: @query

      @refresh()

  methods:
    exact: exact
    approximate: approximate

    query: ->
      chain = Records.memberships.collection.chain()
      switch @$route.query.subgroups
        when 'mine'
          chain = chain.find(groupId: {$in: intersection(@group.organisationIds(), Session.user().groupIds())})
        when 'none'
          chain = chain.find(groupId: @group.id)
        else
          chain = chain.find(groupId: {$in: @group.organisationIds()})

      chain = chain.sort (a, b) =>
        return -1 if (a.groupId == @group.id)
        return 1 if (b.groupId == @group.id)
        return 0

      userIds = []
      membershipIds = []
      chain.data().forEach (m) ->
        if !userIds.includes(m.userId)
          userIds.push(m.userId)
          membershipIds.push(m.id)

      # @memberships = Records.memberships.collection.find(id: {$in: membershipIds})

      # drop the chain, get a new one

      chain = Records.memberships.collection.chain().find(id: {$in: membershipIds})

      if @$route.query.q
        users = Records.users.collection.find
          $or: [
            {name: {'$regex': ["^#{@$route.query.q}", "i"]}},
            {email: {'$regex': ["#{@$route.query.q}", "i"]}},
            {username: {'$regex': ["^#{@$route.query.q}", "i"]}},
            {name: {'$regex': [" #{@$route.query.q}", "i"]}}
          ]
        chain = chain.find(userId: {$in: map(users, 'id')})

      switch @$route.query.filter
        when 'admin'
          chain = chain.find(admin: true)
        when 'accepted'
          chain = chain.find(acceptedAt: { $ne: null })
        when 'pending'
          chain = chain.find(acceptedAt: null)

      chain = chain.simplesort('id', true)

      @memberships = chain.data()

    refresh: ->
      @loader.fetchRecords
        from: 0
        q: @$route.query.q
        order: @order
        filter: @$route.query.filter
        subgroups: @$route.query.subgroups
      @query()

    invite: ->
      EventBus.$emit('openModal',
                      component: 'GroupInvitationForm',
                      props:
                        group: @group)

  computed:
    membershipRequestsPath: -> LmoUrlService.membershipRequest(@group)
    showLoadMore: -> !@loader.exhausted
    totalRecords: ->
      if @pending
        @group.pendingMembershipsCount
      else
        @group.membershipsCount - @group.pendingMembershipsCount

    canAddMembers: ->
      AbilityService.canAddMembersToGroup(@group) && !@pending

    showAdminWarning: ->
      @group.adminsInclude(Session.user()) &&
      @group.adminMembershipsCount < 2 &&
      (@group.membershipsCount - @group.adminMembershipsCount) > 0

  watch:
    '$route.query': 'refresh'


</script>

<template lang="pug">
.members-panel
  loading(v-if="!group")
  div(v-if="group")
    v-alert.my-2(v-if="showAdminWarning" color="primary" type="warning")
      template(slot="default")
        span(v-t="'memberships_page.only_one_admin'")

    v-layout.py-2(align-center wrap)
      v-menu
        template(v-slot:activator="{ on, attrs }")
          v-btn.members-panel__filters.mr-2.text-lowercase(v-on="on" v-bind="attrs" text)
            span(v-if="$route.query.filter == 'admin'" v-t="'members_panel.order_by_admin_desc'")
            span(v-if="$route.query.filter == 'pending'" v-t="'members_panel.invitations'")
            span(v-if="$route.query.filter == 'accepted'" v-t="'members_panel.accepted'")
            span(v-if="!$route.query.filter" v-t="'members_panel.everyone'")
            v-icon mdi-menu-down
        v-list(dense)
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: null})")
            v-list-item-title(v-t="'members_panel.everyone'")
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: 'accepted'})")
            v-list-item-title(v-t="'members_panel.accepted'")
          v-list-item.members-panel__filters-admins(:to="mergeQuery({filter: 'admin'})")
            v-list-item-title(v-t="'members_panel.order_by_admin_desc'")
          v-list-item.members-panel__filters-invitations(:to="mergeQuery({filter: 'pending'})")
            v-list-item-title(v-t="'members_panel.invitations'")
      v-text-field.mr-2(clearable hide-details solo :value="$route.query.q" @input="onQueryInput" :placeholder="$t('navbar.search_members', {name: group.name})" append-icon="mdi-magnify")
      v-btn.membership-card__invite.mr-2(color="primary" v-if='canAddMembers' @click="invite()" v-t="'common.action.invite'")
      shareable-link-modal(v-if='canAddMembers' :group="group")
      v-btn.group-page__requests-tab(:to="urlFor(group, 'members/requests')" v-t="'members_panel.requests'")

    v-card(outlined)
      div(v-if="loader.status == 403")
        p.pa-4.text-center(v-t="'error_page.forbidden'")
      div(v-else)
        p.pa-4.text-center(v-if="!memberships.length" v-t="'common.no_results_found'")
        v-list(v-else three-line)
          v-list-item(v-for="membership in memberships" :key="membership.id")
            v-list-item-avatar(size='48')
              router-link(:to="urlFor(membership.user())")
                user-avatar(:user='membership.user()' size='48')
            v-list-item-content
              v-list-item-title
                router-link(:to="urlFor(membership.user())") {{ membership.user().nameOrEmail() }}
                space
                span.caption(v-if="$route.query.subgroups") {{membership.group().name}}
                space
                span.title.caption {{membership.title}}
                span(v-if="$route.query.q")
                  space
                  span.caption {{membership.user().email}}
                span(v-if="membership.admin")
                  space
                  v-chip(small outlined label v-t="'members_panel.admin'")
                  space
                span.caption.grey--text(v-if="membership.acceptedAt")
                  span(v-t="'common.action.joined'")
                  space
                  time-ago(:date="membership.acceptedAt")
                span.caption.grey--text(v-if="!membership.acceptedAt")
                  template(v-if="membership.inviterId")
                    span(v-t="{path: 'members_panel.invited_by_name', args: {name: membership.inviter().name}}")
                    space
                    time-ago(:date="membership.createdAt")
                  template(v-if="!membership.inviterId")
                    span(v-t="'members_panel.header_invited'")
                    space
                    time-ago(:date="membership.createdAt")
              v-list-item-subtitle
                span(v-if="membership.groupId != group.id")
                  span(v-t="{path: 'members_panel.only_in_subgroups', args: {name: membership.group().name}}")
                  space
                span(v-if="membership.acceptedAt") {{ (membership.user().shortBio || '').replace(/<\/?[^>]+(>|$)/g, "") }}
            v-list-item-action
              membership-dropdown(v-if="membership.groupId == group.id" :membership="membership")

        .d-flex.justify-center
          .d-flex.flex-column.align-center
            .text--secondary(v-if='group.parentId')
              | {{memberships.length}} / {{loader.total}}
            .text--secondary(v-if='!group.parentId')
              | {{memberships.length}} / {{group.orgMembersCount}}
            v-btn.my-2.members-panel__show-more(outlined color='accent' v-if="memberships.length < loader.total && !loader.exhausted" :loading="loader.loading" @click="loader.fetchRecords({per: 50})")
              span(v-t="'common.action.load_more'")

</template>
