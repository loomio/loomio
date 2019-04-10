<style lang="scss">
@import 'mixins';
@import 'lmo_card';
@import 'variables';
.membership-requests-page {
  @include lmoRow;
}

.membership-requests-page__pending-requests,
.membership-requests-page__previous-requests {
  @include card;
  ul {
    list-style: none;
    padding-left: 0px;
  }
}

.membership-requests-page__actions {
  height: 60px;
  margin-top: 5px;
  button { margin-right: 10px; }
}

.membership-requests-page__pending-request-email,
.membership-requests-page__pending-request-date,
.membership-requests-page__previous-request-email,
.membership-requests-page__previous-request-response {
  color: $grey-on-white;
  font-size: 12px;
}

.membership-requests-page__previous-request {
  margin: 16px 0;
}
</style>

<script lang="coffee">
AppConfig      = require 'shared/services/app_config'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
FlashService   = require 'shared/services/flash_service'

_isEmpty     = require 'lodash/isEmpty'

module.exports =
  data: ->
    group: {}
  created: ->
    # EventBus.broadcast $rootScope, 'currentComponent', { page: 'membershipRequestsPage'}
    @init()
  methods:
    init: ->
      Records.groups.findOrFetchById(@$route.params.key).then (group) =>
      #   if AbilityService.canManageMembershipRequests(group)
      #     @group = group
      #     Records.membershipRequests.fetchPendingByGroup(group.key, per: 100)
      #     Records.membershipRequests.fetchPreviousByGroup(group.key, per: 100)
      #   else
      #     EventBus.broadcast $rootScope, 'pageError', {status: 403}
      # , (error) ->
      #     EventBus.broadcast $rootScope, 'pageError', {status: 403}

    approve: (membershipRequest) ->
      Records.membershipRequests.approve(membershipRequest).then =>
        # FlashService.success "membership_requests_page.messages.request_approved_success"

    ignore: (membershipRequest) ->
      Records.membershipRequests.ignore(membershipRequest).then =>
        # FlashService.success "membership_requests_page.messages.request_ignored_success"
  computed:
    pendingRequests: ->
      @group.pendingMembershipRequests()

    previousRequests: ->
      @group.previousMembershipRequests()

    noPendingRequests: ->
      @pendingRequests.length == 0

    isEmptyGroup: ->
      _isEmpty @group
</script>

<template>
  <div class="loading-wrapper lmo-one-column-layout">
    <loading v-if="isEmptyGroup"></loading>
    <main v-if="!isEmptyGroup" class="membership-requests-page">
      <div class="lmo-group-theme-padding"></div>
      <group-theme :group="group"></group-theme>
      <div class="membership-requests-page__pending-requests">
        <h2 v-t="'membership_requests_page.heading'" class="lmo-h2"></h2>
        <ul v-if="group.hasPendingMembershipRequests()">
          <li layout="row" v-for="request in pendingRequests()" :key="request.id" class="lmo-flex membership-requests-page__pending-request">
            <user-avatar :user="request.actor()" size="medium" class="lmo-margin-right"></user-avatar>
            <div layout="column" class="lmo-flex">
              <span class="membership-requests-page__pending-request-name">
                <strong>{{request.actor().name}}</strong>
              </span>
              <div class="membership-requests-page__pending-request-email">{{request.email}}</div>
              <div class="membership-requests-page__pending-request-date">
                <time-ago :date="request.createdAt"></time-ago>
              </div>
              <div class="membership-requests-page__pending-request-introduction">{{request.introduction}}</div>
              <div class="membership-requests-page__actions">
                <v-btn @click="ignore(request)" v-t="'membership_requests_page.ignore'" class="membership-requests-page__ignore"></v-btn>
                <v-btn @click="approve(request)" v-t="'membership_requests_page.approve'" class="md-primary md-raised membership-requests-page__approve"></v-btn>
              </div>
            </div>
          </li>
        </ul>
        <div v-if="!group.hasPendingMembershipRequests()" v-t="'membership_requests_page.no_pending_requests'" class="membership-requests-page__no-pending-requests"></div>
      </div>
      <div class="membership-requests-page__previous-requests">
        <h3 v-t="'membership_requests_page.previous_requests'" class="lmo-card-heading"></h3>
        <ul v-if="group.hasPreviousMembershipRequests()">
          <li layout="row" v-for="request in previousRequests()" :key="request.id" class="lmo-flex membership-requests-page__previous-request">
            <user-avatar :user="request.actor()" size="medium" class="lmo-margin-right"></user-avatar>
            <div layout="column" class="lmo-flex">
              <span class="membership-requests-page__previous-request-name">
                <strong>{{request.actor().name}}</strong>
              </span>
              <div class="membership-requests-page__previous-request-email">{{request.email}}</div>
              <div class="membership-requests-page__previous-request-response">
                <span v-t="{ path: 'membership_requests_page.previous_request_response', args: { response: request.formattedResponse(), responder: request.responder().name } }"></span>
                <span>·</span>
                <time-ago :date="request.respondedAt"></time-ago>
              </div>
              <div class="membership-requests-page__previous-request-introduction">{{request.introduction}}</div>
            </div>
          </li>
        </ul>
        <div v-if="!group.hasPreviousMembershipRequests()" v-t="'membership_requests_page.no_previous_requests'" class="membership-requests-page__no-previous-requests"></div>
      </div>
    </main>
  </div>
</template>
