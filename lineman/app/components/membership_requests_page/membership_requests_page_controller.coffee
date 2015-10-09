angular.module('loomioApp').controller 'MembershipRequestsPageController', ($routeParams, $rootScope, Records, LoadingService, AbilityService, FlashService) ->
  $rootScope.$broadcast('currentComponent', { page: 'membershipRequestsPage'})

  @init = (group) =>
    return if @group? or !group?
    if AbilityService.canManageMembershipRequests(group)
      @group = group
      Records.membershipRequests.fetchPendingByGroup(group.key, per: 100)
      Records.membershipRequests.fetchPreviousByGroup(group.key, per: 100)
    else
      $rootScope.$broadcast('pageError', {status: 403})

  Records.groups.findOrFetchById($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

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
