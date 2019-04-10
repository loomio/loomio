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
Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'
urlFor         = require 'src/mixins/url_for'

module.exports =
  mixins: [urlFor]
  props:
    group: Object
  created: ->
    if @canManageMembershipRequests()
      Records.membershipRequests.fetchPendingByGroup(@group.key)
  methods:
    orderedPendingMembershipRequests: ->
      _.slice(_.orderBy(@group.pendingMembershipRequests(), 'createdAt', 'desc'), 0, 5)

    canManageMembershipRequests: ->
      AbilityService.canManageMembershipRequests(@group)
</script>

<template>
    <div class="blank">
      <section v-if="canManageMembershipRequests() && group.hasPendingMembershipRequests()" class="membership-requests-card">
        <h2 v-t="'membership_requests_card.heading'" class="lmo-card-heading"></h2>
        <ul md-list>
          <li md-list-item v-for="request in orderedPendingMembershipRequests()" :key="request.id" class="membership-requests-card__request">
            <router-link layout="row" :to="urlFor(group, 'membership_requests')" title="$t('membership_requests_card.manage_requests')" class="md-button membership-requests-card__request-link lmo-flex">
              <user-avatar :user="request.actor()" size="medium" class="lmo-margin-right"></user-avatar>
              <div layout="column" class="lmo-flex">
                <div class="lmo-truncate membership-requests-card__requestor-name">{{request.actor().name || request.actor().email}}</div>
                <div class="lmo-truncate membership-requests-card__requestor-introduction">{{request.introduction}}</div>
              </div>
            </router-link>
          </li>
        </ul>
        <router-link :to="urlFor(group, 'membership_requests')" class="membership-requests-card__link lmo-card-minor-action">
          <span v-t="{ path: 'membership_requests_card.manage_requests_with_count', args: { count: group.pendingMembershipRequests().length } }"></span>
        </router-link>
      </section>
    </div>
</template>
