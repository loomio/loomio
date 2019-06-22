<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import RecordLoader   from '@/shared/services/record_loader'
import fromNow        from '@/mixins/from_now'
import UrlFor         from '@/mixins/url_for'
import Session        from '@/shared/services/session'
import AnnouncementModalMixin from '@/mixins/announcement_modal'
import WatchRecords from '@/mixins/watch_records'
import {includes, some} from 'lodash'
import LmoUrlService from '@/shared/services/lmo_url_service'

export default
  mixins: [fromNow, AnnouncementModalMixin, WatchRecords, UrlFor]

  data: ->
    group: Records.groups.fuzzyFind(@$route.params.key)
    fragment: ''
    loader: null
    includeSubgroups: false
    order: 'created_at desc'
    orders: [
      {text: @$t('members_panel.order_by_name'),  value:'users.name' }
      {text: @$t('members_panel.order_by_created'), value:'created_at' }
      {text: @$t('members_panel.order_by_created_desc'), value:'created_at desc' }
      {text: @$t('members_panel.order_by_admin_desc'), value:'admin desc' }
    ]

    per: 25
    from: 0
    headers: [
      {text: '', align: 'center', sortable: false},
      {text: @$t('members_panel.header_name'), sortable: false},
      {text: @$t('members_panel.header_username'), sortable: false},
      {text: @$t('members_panel.header_role'), sortable: false},
      {text: @$t('members_panel.header_invited_by'), sortable: false},
      {text: @$t('members_panel.header_invited'), sortable: false},
      {text: @$t('members_panel.header_actions'), sortable: false},
    ]

  created: ->
    @loader = new RecordLoader
      collection: 'memberships'
      path: 'autocomplete'
      params:
        q: @fragment
        group_id: @group.id
        per: @per
        from: @from
        order: @order

    @loader.fetchRecords()

    @watchRecords
      collections: ['memberships']
      query: @runQuery

  methods:
    runQuery: ->
      chain = Records.memberships.collection.chain()
      if @includeSubgroups
        chain = chain.find(groupId: {$in: @group.organisationIds()})
      else
        chain = chain.find(groupId: @group.id)

      if @fragment
        chain = chain.where (membership) =>
          some [membership.user().name, membership.user().username], (name) =>
            RegExp("^#{@fragment}", "i").test(name) or RegExp(" #{@fragment}", "i").test(name)

      switch @order
        when 'users.name'
          chain = chain.sort (ma,mb) ->
            a = ma.user().name.toLowerCase()
            b = mb.user().name.toLowerCase()
            switch
              when a == b then 0
              when a > b then 1
              when a < b then -1
        when 'admin desc'
          chain = chain.simplesort('admin', true)
        when 'created_at'
          chain = chain.simplesort('createdAt')
        when 'created_at desc'
          chain = chain.simplesort('createdAt', true)

      @memberships = chain.limit(@loader.numRequested).data()

    fetch: ->
      @loader.fetchRecords
        q: @fragment
        from: @from
        order: @order
        include_subgroups: @includeSubgroups

    show: ->
      return false if (@recordCount() == 0 && @pending)
      @initialFetch() if @canView()
      @canView()

    canView: ->
      if @pending
        AbilityService.canViewPendingMemberships(@group)
      else
        AbilityService.canViewMemberships(@group)

    recordCount: ->

    toggleSearch: ->
      @fragment = ''
      @searchOpen = !@searchOpen
      @$nextTick => document.querySelector('.membership-card__search input').focus()


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

    componentType: (membership) ->
      if membership.acceptedAt
        'router-link'
      else
        'div'

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
    order: ->
      @fetch()
      @runQuery()
    page: ->
      @fetch()
      @runQuery()
    fragment: ->
      @fetch()
      @runQuery()
    includeSubgroups: ->
      @fetch()
      @runQuery()
</script>

<template lang="pug">
div.members-panel
  v-toolbar(text align-center)
    v-toolbar-items
      v-text-field.members-panel__filter(solo flat v-model="fragment" append-icon="mdi-magnify" :label="$t('common.action.search')" clearable)
    v-toolbar-items
      span(v-t="'members_panel.sort'")
      v-select(solo flat v-model="order" :items="orders" :label="$t('members_panel.order_label')")
    //- just for group admins
    v-switch(v-if="currentUserIsAdmin && group.hasSubgroups()" v-model="includeSubgroups" :label="$t('discussions_panel.include_subgroups')")
    v-spacer
    v-btn.membership-requests-link(text color="primary" :to="membershipRequestsPath" v-t="'members_panel.view_requests'")
    v-btn.membership-card__invite(text color="primary" v-if='canAddMembers()' @click="invite()" v-t="'common.action.invite'")
  v-progress-linear(indeterminate :active="loader.loading")
  v-data-table.members-panel__table(:items="memberships" :headers="headers" disable-initial-sort :total-items="totalRecords" hide-actions)
    template(v-slot:no-results)
      | No results
    template(v-slot:items="props")
      td
        v-icon(v-if="props.item.admin") mdi-star
      td.members-panel__name(v-if="props.item.acceptedAt")
        v-layout(align-center)
          user-avatar.mr-3(:user='props.item.user()', size='forty')
          router-link(:to="urlFor(props.item.user())") {{props.item.user().name}}
      td.members-panel__name(v-else)
        v-layout(align-center)
          user-avatar.mr-3(:user='props.item.user()', size='forty')
          span {{props.item.user().email || props.item.user().name}}
      td {{props.item.user().username}}
      td.members-panel__title {{props.item.title}}
      td(v-if="includeSubgroups") {{props.item.group().name}}
      td {{props.item.inviter() && props.item.inviter().name}}
      td
        timeAgo(:date="props.item.createdAt")
      td
        membership-dropdown(:membership="props.item")

  v-layout(align-center)
    span(v-if="!includeSubgroups" v-t="{path: 'members_panel.loaded_of_total', args: {loaded: loader.numLoaded, total: totalRecords}}")
    v-btn(v-if="showLoadMore" :loading="loader.loading" @click="loader.loadMore()" v-t="'common.action.load_more'")

    //- v-list(two-line avatar)
    //-   v-list-item(v-if="!searchOpen")
    //-     v-list-item-content
    //-       span.grey--text(v-t='{ path: cardTitle(), args: { values: { pollType: pollType } } }')
    //-     v-list-item-action
    //-       v-btn.membership-card__search-button(icon @click="toggleSearch()")
    //-         v-icon mdi-magnify
    //-
    //-   v-list-item(v-if="searchOpen")
    //-     v-text-field.membership-card__filter(autofocus v-model="fragment" :placeholder="$t('memberships_page.fragment_placeholder')")
    //-       template(slot="append")
    //-         v-btn(icon @click="toggleSearch()")
    //-           v-icon mdi-close
    //-
    //-   v-list-item.membership-card__membership.membership-card__invite(v-if='!searchOpen && canAddMembers()', @click="invite()")
    //-     v-list-item-avatar
    //-       v-avatar(:size='40')
    //-         v-icon(color="primary") mdi-plus
    //-     v-list-item-content
    //-       v-list-item-title(v-t="'membership_card.invite_to_' + group.targetModel().constructor.singular")

</template>
