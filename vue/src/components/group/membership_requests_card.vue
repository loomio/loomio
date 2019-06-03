<style lang="scss">
@import 'app.scss';


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
import urlFor         from '@/mixins/url_for'
import { slice, orderBy } from 'lodash'
import WatchRecords from '@/mixins/watch_records'

export default
  mixins: [urlFor, WatchRecords]
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
    v-list-tile.membership-requests-card__request(v-for='request in orderedPendingMembershipRequests()', :key='request.id' :to="urlFor(group, 'membership_requests')")
      v-list-tile-avatar
        user-avatar.lmo-margin-right(:user='request.actor()', size='forty')
      v-list-tile-content
        //- router-link.md-button.membership-requests-card__request-link.lmo-flex(layout='row', :to="urlFor(group, 'membership_requests')", title="$t('membership_requests_card.manage_requests')")
        v-list-tile-title.membership-requests-card__requestor-name {{request.actor().name || request.actor().email}}
        v-list-tile-sub-title.membership-requests-card__requestor-introduction {{request.introduction}}
  v-card-actions
    v-btn.membership-requests-card__link(flat :to="urlFor(group, 'membership_requests')")
      span(v-t="{ path: 'membership_requests_card.manage_requests_with_count', args: { count: group.pendingMembershipRequests().length } }")
</template>
