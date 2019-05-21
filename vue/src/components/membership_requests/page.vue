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
import AppConfig      from '@/shared/services/app_config'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import Flash   from '@/shared/services/flash'
import { isEmpty }    from 'lodash'

export default
  data: ->
    group: {}
    pendingRequests: []
    previousRequests: []

  created: ->
    EventBus.$emit 'currentComponent', { page: 'membershipRequestsPage'}
    @init()

  methods:
    init: ->
      Records.groups.findOrFetchById(@$route.params.key).then (group) =>
        if AbilityService.canManageMembershipRequests(group)
          @group = group
          Records.membershipRequests.fetchPendingByGroup(group.key, per: 100)
          Records.membershipRequests.fetchPreviousByGroup(group.key, per: 100)
          Records.view
            name: "membershipRequestsFor#{@group.id}"
            collections: ['membershipRequests']
            query: (store) =>
              @pendingRequests = @group.pendingMembershipRequests()
              @previousRequests = @group.previousMembershipRequests()
        else
          EventBus.$emit 'pageError', {status: 403}
      , (error) ->
          EventBus.$emit 'pageError', {status: 403}

    approve: (membershipRequest) ->
      Records.membershipRequests.approve(membershipRequest).then =>
        @init()
        Flash.success "membership_requests_page.messages.request_approved_success"

    ignore: (membershipRequest) ->
      Records.membershipRequests.ignore(membershipRequest).then =>
        @init()
        Flash.success "membership_requests_page.messages.request_ignored_success"

  computed:
    isEmptyGroup: -> isEmpty @group

</script>

<template lang="pug">
  .loading-wrapper.lmo-one-column-layout
    loading(v-if='isEmptyGroup')
    main.membership-requests-page(v-if='!isEmptyGroup')
      .lmo-group-theme-padding
      group-theme(:group='group')
      .membership-requests-page__pending-requests
        h2.lmo-h2(v-t="'membership_requests_page.heading'")
        ul(v-if='pendingRequests.length')
          li.lmo-flex.membership-requests-page__pending-request(layout='row', v-for='request in pendingRequests', :key='request.id')
            user-avatar.lmo-margin-right(:user='request.actor()', size='medium')
            .lmo-flex(layout='column')
              span.membership-requests-page__pending-request-name
                strong {{request.actor().name}}
              .membership-requests-page__pending-request-email {{request.email}}
              .membership-requests-page__pending-request-date
                time-ago(:date='request.createdAt')
              .membership-requests-page__pending-request-introduction {{request.introduction}}
              .membership-requests-page__actions
                v-btn.membership-requests-page__ignore(@click='ignore(request)', v-t="'membership_requests_page.ignore'")
                v-btn.md-primary.md-raised.membership-requests-page__approve(@click='approve(request)', v-t="'membership_requests_page.approve'")
        .membership-requests-page__no-pending-requests(v-if='pendingRequests.length == 0', v-t="'membership_requests_page.no_pending_requests'")
      .membership-requests-page__previous-requests
        h3.lmo-card-heading(v-t="'membership_requests_page.previous_requests'")
        ul(v-if='previousRequests.length')
          li.lmo-flex.membership-requests-page__previous-request(layout='row', v-for='request in previousRequests', :key='request.id')
            user-avatar.lmo-margin-right(:user='request.actor()', size='medium')
            .lmo-flex(layout='column')
              span.membership-requests-page__previous-request-name
                strong {{request.actor().name}}
              .membership-requests-page__previous-request-email {{request.email}}
              .membership-requests-page__previous-request-response
                span(v-t="{ path: 'membership_requests_page.previous_request_response', args: { response: request.formattedResponse(), responder: request.responder().name } }")
                span ·
                time-ago(:date='request.respondedAt')
              .membership-requests-page__previous-request-introduction {{request.introduction}}
        .membership-requests-page__no-previous-requests(v-if='previousRequests.length == 0', v-t="'membership_requests_page.no_previous_requests'")

</template>
