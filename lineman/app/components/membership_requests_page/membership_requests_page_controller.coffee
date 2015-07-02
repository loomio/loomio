angular.module('loomioApp').controller 'MembershipRequestsPageController', ($routeParams, $rootScope, Records, LoadingService, AbilityService, FlashService) ->
  $rootScope.$broadcast('currentComponent', { page: 'membershipRequestsPage'})

  @init = (group) =>
    @group = group
    Records.membershipRequests.fetchPendingByGroup(group.key, per: 100)
    Records.membershipRequests.fetchRespondedToByGroup(group.key, per: 100)

  Records.groups.findOrFetchByKey($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error, group)

  @pendingRequests = =>
    @group.pendingMembershipRequests()

  @approve = (membershipRequest) =>
    Records.membershipRequests.approve(membershipRequest)

  return
