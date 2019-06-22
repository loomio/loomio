<style lang="scss">
.membership-requests-card__request-link {
  margin: 0;
  padding: 8px 0;
  width: 100%;
  text-transform: none;
  text-align: left;
}
</style>

<script lang="coffee">
import Records        from '@/shared/services/records'
import AbilityService from '@/shared/services/ability_service'
import UrlFor         from '@/mixins/url_for'
import { slice, orderBy } from 'lodash'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [UrlFor, WatchRecords]
  props:
    group: Object
  data: ->
    membershipRequests: []
  created: ->
    @watchRecords
      collections: ['membershipRequests']
      query: (store) =>
        @membershipRequests = @group.pendingMembershipRequests()
    @init()
  methods:
    init: ->
      if @canManageMembershipRequests()
        Records.membershipRequests.fetchPendingByGroup(@group.key)

    orderedPendingMembershipRequests: ->
      slice(orderBy(@membershipRequests, 'createdAt', 'desc'), 0, 5)

    canManageMembershipRequests: ->
      AbilityService.canManageMembershipRequests(@group)
</script>

<template lang="pug">
v-card.membership-requests-card(v-if='canManageMembershipRequests() && membershipRequests.length')
  v-list(two-line avatar)
    v-subheader(v-t="'membership_requests_card.heading'")
    v-list-item.membership-requests-card__request(v-for='request in orderedPendingMembershipRequests()', :key='request.id' :to="urlFor(group, 'membership_requests')")
      v-list-item-avatar
        user-avatar(:user='request.actor()', size='forty')
      v-list-item-content
        v-list-item-title.membership-requests-card__requestor-name {{request.actor().name || request.actor().email}}
        v-list-item-subtitle.membership-requests-card__requestor-introduction {{request.introduction}}
  v-card-actions
    v-btn.membership-requests-card__link(flat :to="urlFor(group, 'membership_requests')")
      span(v-t="{ path: 'membership_requests_card.manage_requests_with_count', args: { count: group.pendingMembershipRequests().length } }")
</template>
