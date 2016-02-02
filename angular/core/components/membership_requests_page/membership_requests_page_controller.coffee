angular.module('loomioApp').controller 'MembershipRequestsPageController', ($routeParams, $rootScope, Records, LoadingService, AbilityService, FlashService, AppConfig) ->
  $rootScope.$broadcast('currentComponent', { page: 'membershipRequestsPage'})

  @init = =>
    Records.groups.findOrFetchById($routeParams.key).then (group) =>
      if AbilityService.canManageMembershipRequests(group)
        @group = group
        Records.membershipRequests.fetchPendingByGroup(group.key, per: 100)
        Records.membershipRequests.fetchPreviousByGroup(group.key, per: 100)
      else
        $rootScope.$broadcast('pageError', {status: 403})
    , (error) ->
        $rootScope.$broadcast('pageError', {status: 403})

  @init()

  @pendingRequests = =>
    @group.pendingMembershipRequests()

   @previousRequests = =>
    @group.previousMembershipRequests()

  @approve = (membershipRequest) =>
    Records.membershipRequests.approve(membershipRequest).then ->
      FlashService.success "membership_requests_page.messages.request_approved_success"

  @ignore = (membershipRequest) =>
    Records.membershipRequests.ignore(membershipRequest).then ->
      FlashService.success "membership_requests_page.messages.request_ignored_success"

  @noPendingRequests = =>
    @pendingRequests.length == 0

  return
