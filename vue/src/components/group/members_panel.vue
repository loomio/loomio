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
    per: 100
    from: 0
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
          from: @from
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
        # when 'all'
        #   chain = chain.find(groupId: {$in: @group.organisationIds()})

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
        when 'pending'
          chain = chain.find(acceptedAt: null)

      userIds = []
      membershipIds = chain.simplesort('groupId').data().filter (m) ->
        if userIds.includes(m.userId)
          false
        else
          userIds.push(m.userId)
          true
      .map (m) -> m.id

      chain = chain.find(id: {$in: membershipIds})

      if @$route.query.q
        chain = chain.sort (a,b) ->
          return -1 if a.user().name < b.user().name
          return 1  if a.user().name > b.user().name
          return 0
      else
        chain = chain.simplesort('createdAt', true)

      @memberships = chain.data()

    refresh: ->
      @fetch()
      @query()

    fetch: ->
      @loader.fetchRecords
        q: @$route.query.q
        from: @from
        order: @order
        filter: @$route.query.filter
        subgroups: @$route.query.subgroups

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

    onlyOneAdminWithMultipleMembers: ->
      (@group.adminMembershipsCount < 2) && ((@group.membershipsCount - @group.adminMembershipsCount) > 0)

  watch:
    '$route.query': 'refresh'


</script>

<template lang="pug">
.members-panel
  loading(v-if="!group")
  div(v-if="group")
    v-alert.my-2(v-model="onlyOneAdminWithMultipleMembers" color="primary" type="warning")
      template(slot="default")
        span(v-t="'memberships_page.only_one_admin'")

    v-layout.py-2(align-center wrap)
      v-menu
        template(v-slot:activator="{ on, attrs }")
          v-btn.members-panel__filters.mr-2.text-lowercase(v-on="on" v-bind="attrs" text)
            span(v-if="$route.query.filter == 'admin'" v-t="'members_panel.order_by_admin_desc'")
            span(v-if="$route.query.filter == 'pending'" v-t="'members_panel.invitations'")
            span(v-if="!$route.query.filter" v-t="'members_panel.everyone'")
            v-icon mdi-menu-down
        v-list(dense)
          v-list-item.members-panel__filters-everyone(:to="mergeQuery({filter: null})")
            v-list-item-title(v-t="'members_panel.everyone'")
          v-list-item.members-panel__filters-admins(:to="mergeQuery({filter: 'admin'})")
            v-list-item-title(v-t="'members_panel.order_by_admin_desc'")
          v-list-item.members-panel__filters-invitations(:to="mergeQuery({filter: 'pending'})")
            v-list-item-title(v-t="'members_panel.invitations'")
      v-text-field.mr-2(clearable hide-details solo :value="$route.query.q" @input="onQueryInput" :placeholder="$t('navbar.search_members', {name: group.name})" append-icon="mdi-magnify")
      v-btn.membership-card__invite.mr-2(color="primary" v-if='canAddMembers' @click="invite()" v-t="'common.action.invite'")
      shareable-link-modal(v-if='canAddMembers' :group="group")
      v-btn.group-page__requests-tab(:to="urlFor(group, 'members/requests')" v-t="'members_panel.requests'")

    div(v-if="loader.status == 403")
      p.pa-4.text-center(v-t="'error_page.forbidden'")
    div(v-else)
      p.pa-4.text-center(v-if="!memberships.length" v-t="'common.no_results_found'")
      v-simple-table(v-else)
        template(v-slot:default)
          tbody
            tr(v-for="membership in memberships" :key="membership.id")
              td.shrink
                user-avatar(:user='membership.user()' size='32')
              td
                router-link(:to="urlFor(membership.user())") {{ membership.user().name }}
                span(v-if="membership.title")
                  mid-dot
                  span {{membership.title}}
                span(v-if="membership.user().shortBio")
                  space
                  span.caption.grey--text {{ membership.user().simpleBio() }}
              td.shrink(v-if="$route.query.subgroups") {{membership.group().name}}
              td.shrink
                v-chip(v-if="membership.admin" small outlined label v-t="'members_panel.admin'")
              td.shrink
                membership-dropdown(:membership="membership")
      v-layout(justify-center)
        v-btn.my-2(outlined color='accent' v-if="showLoadMore" :loading="loader.loading" @click="loader.fetchRecords()" v-t="'common.action.load_more'")

</template>

<style lang="sass">
.members-panel
  .grow
    width: 100%
  .shrink
    width: 0.1%
    white-space: nowrap
</style>
