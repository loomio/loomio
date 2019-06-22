<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import ModalService   from '@/shared/services/modal_service'
import RecordLoader   from '@/shared/services/record_loader'
import fromNow        from '@/mixins/from_now'
import AnnouncementModalMixin from '@/mixins/announcement_modal'

export default
  mixins: [fromNow, AnnouncementModalMixin]
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
      @openAnnouncementModal(Records.announcements.buildFromModel(@group.targetModel()))

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
  v-list(two-line avatar)
    v-list-item(v-if="!searchOpen")
      v-list-item-content
        span.grey--text(v-t='{ path: cardTitle(), args: { values: { pollType: pollType } } }')
      v-list-item-action
        v-btn.membership-card__search-button(icon @click="toggleSearch()")
          v-icon mdi-magnify

    v-list-item(v-if="searchOpen")
      v-text-field.membership-card__filter(autofocus v-model="fragment" :placeholder="$t('memberships_page.fragment_placeholder')")
        template(slot="append")
          v-btn(icon @click="toggleSearch()")
            v-icon mdi-close

    v-list-item.membership-card__membership.membership-card__invite(v-if='!searchOpen && canAddMembers()', @click="invite()")
      v-list-item-avatar
        v-avatar(:size='40')
          v-icon(color="primary") mdi-plus
      v-list-item-content
        v-list-item-title(v-t="'membership_card.invite_to_' + group.targetModel().constructor.singular")

    v-list-item(v-for='membership in orderedMemberships()', :key='membership.id', data-username='membership.user().username')
      v-list-item-avatar
        user-avatar(:user='membership.user()', size='forty', :coordinator='membership.admin', :no-link='!membership.acceptedAt')
      v-list-item-content
        v-list-item-title {{membership.userName() || membership.user().email }}
        v-list-item-subtitle.membership-card__last-seen
          span(v-if='membership.user().lastSeenAt', v-t="{ path: 'user_page.online_field', args: { value: fromNow(membership.user().lastSeenAt) } }")
          span(v-if='!membership.acceptedAt', v-t="{ path: 'user_page.invited', args: { value: fromNow(membership.user().createdAt) } }")
      v-list-item-action
        membership-dropdown(:membership="membership")
    loading(v-if='loader.loading')
  v-card-actions(v-if='showLoadMore()')
    v-btn(text color="accent", v-if='showLoadMore()', @click='loader.loadMore()', v-t="'common.action.load_more'")
    span {{recordsDisplayed()}} / {{recordCount()}}
</template>
