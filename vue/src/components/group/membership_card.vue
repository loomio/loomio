<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import RecordLoader   from '@/shared/services/record_loader'
import fromNow        from '@/mixins/from_now'

export default
  mixins: [fromNow]
  props:
    group: Object
    pending: Boolean
  data: ->
    fragment: ''
    plusUser: Records.users.build(avatarKind: 'mdi-plus')
    fetched: false
    searchOpen: false
    loader: new RecordLoader
      collection: 'memberships'
      params:
        per: 20
        pending: @pending
        group_id: @group.id

  methods:
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
      if @pending
        @group.pendingMembershipsCount
      else
        @group.membershipsCount - @group.pendingMembershipsCount

    toggleSearch: ->
      @fragment = ''
      @searchOpen = !@searchOpen
      @$nextTick => document.querySelector('.membership-card__search input').focus()

    showLoadMore: ->
      @loader.numRequested < @recordCount() && _.isEmpty @fragment && !@loader.loading

    canAddMembers: ->
      AbilityService.canAddMembers(@group.targetModel().group() || @group) && !@pending

    memberships: ->
      if !_.isEmpty @fragment
        _.filter @records(), (membership) =>
          _.includes membership.userName().toLowerCase(), @fragment.toLowerCase()
      else
        @records()

    orderedMemberships: ->
      limit = @loader.numRequested || 10
      _.slice(_.orderBy(@memberships(), ['-admin', '-createdAt']), 0, limit)

    recordsDisplayed: ->
      _.min [@loader.numRequested, @recordCount()]

    initialFetch: ->
      @loader.fetchRecords(per: 4) unless @fetched
      @fetched = true

    records: ->
      if @pending
        @group.pendingMemberships()
      else
        @group.activeMemberships()

    invite: ->
      ModalService.open 'AnnouncementModal', announcement: =>
        Records.announcements.buildFromModel(@group.targetModel())

    fetchMemberships: ->
      return unless !_.isEmpty @fragment
      Records.memberships.fetchByNameFragment(@fragment, @group.key)

    cardTitle: ->
      if @pending
        'membership_card.invitations'
      else
        "membership_card.#{@group.targetModel().constructor.singular}_members"

  computed:
    pollType: ->
      @$t(@group.targetModel().pollTypeKey()) if @group.targetModel().isA('poll')
  watch:
    fragment: ->
      @fetchMemberships()
</script>

<template lang="pug">
v-card.membership-card.lmo-no-print(v-if='show()', :class="{'membership-card--pending': pending}")
  v-layout(justify-space-between)
    v-subheader(v-t='{ path: cardTitle(), args: { values: { pollType: pollType } } }', v-if='!searchOpen')
    v-btn.membership-card__search-button(v-if="!searchOpen" icon @click="toggleSearch()")
      v-icon mdi-magnify
    .membership-card__search(v-if="searchOpen" )
      v-text-field.membership-card__filter(v-model="fragment" :placeholder="$t('memberships_page.fragment_placeholder')")
      v-btn(@click="toggleSearch()")
        v-icon mdi-close

  v-list(two-line)
    plus-button.membership-card__membership.membership-card__invite(v-if='canAddMembers()', :click='invite', :message="'membership_card.invite_to_' + group.targetModel().constructor.singular")
    v-list-tile(v-for='membership in orderedMemberships()', :key='membership.id', data-username='membership.user().username')
      v-list-tile-avatar
        user-avatar.lmo-margin-right(:user='membership.user()', size='medium', :coordinator='membership.admin', :no-link='!membership.acceptedAt')
      v-list-tile-content
        v-list-tile-title {{membership.userName() || membership.user().email }}
        v-list-tile-sub-title.membership-card__last-seen
          span(v-if='membership.user().lastSeenAt', v-t="{ path: 'user_page.online_field', args: { value: fromNow(membership.user().lastSeenAt) } }")
          span(v-if='!membership.acceptedAt', v-t="{ path: 'user_page.invited', args: { value: fromNow(membership.user().createdAt) } }")
      // <membership_dropdown membership="membership"></membership_dropdown>
    loading(v-if='loader.loading')
  v-card-actions(v-if='showLoadMore()')
    v-btn(flat color="accent", v-if='showLoadMore()', @click='loader.loadMore()', v-t="'common.action.load_more'")
    span {{recordsDisplayed()}} / {{recordCount()}}
</template>
