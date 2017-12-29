AppConfig      = require 'shared/services/app_config.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
FlashService   = require 'shared/services/flash_service.coffee'

$controller = ($routeParams, $rootScope) ->
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

$controller.$inject = ['$routeParams', '$rootScope']
angular.module('loomioApp').controller 'MembershipRequestsPageController', $controller
