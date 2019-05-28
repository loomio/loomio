<style lang="scss">
@import 'app.scss';

.membership-requests-card{
  @include card;
}

md-list-item.membership-requests-card__request {
  padding: 0;
}

.membership-requests-card__request-link {
  margin: 0;
  padding: 8px 0;
  width: 100%;
  text-transform: none;
  text-align: left;
}

.membership-requests-card__requestor-name{
  @include md-body-2;
  color: $primary-text-color;
}

.membership-requests-card__requestor-introduction{
  @include fontSmall;
  color: $grey-on-white;
}
.membership-requests-card__pending-requests a{
  color: $grey-on-white;
}
.membership-requests-card__pending-requests a:hover{
  text-decoration: none;
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
  .blank
    section.membership-requests-card(v-if='canManageMembershipRequests() && membershipRequests.length')
      h2.lmo-card-heading(v-t="'membership_requests_card.heading'")
      ul(md-list='')
        li.membership-requests-card__request(md-list-item='', v-for='request in orderedPendingMembershipRequests()', :key='request.id')
          router-link.md-button.membership-requests-card__request-link.lmo-flex(layout='row', :to="urlFor(group, 'membership_requests')", title="$t('membership_requests_card.manage_requests')")
            user-avatar.lmo-margin-right(:user='request.actor()', size='medium')
            .lmo-flex(layout='column')
              .lmo-truncate.membership-requests-card__requestor-name {{request.actor().name || request.actor().email}}
              .lmo-truncate.membership-requests-card__requestor-introduction {{request.introduction}}
      router-link.membership-requests-card__link.lmo-card-minor-action(:to="urlFor(group, 'membership_requests')")
        span(v-t="{ path: 'membership_requests_card.manage_requests_with_count', args: { count: group.pendingMembershipRequests().length } }")
</template>
