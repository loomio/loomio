Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
FlashService   = require 'shared/services/flash_service'
ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'joinGroupButton', ['$rootScope', ($rootScope) ->
  scope: {group: '=', block: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/join_group_button/join_group_button.html'
  replace: true
  controller: ['$scope', ($scope) ->
    Records.membershipRequests.fetchMyPendingByGroup($scope.group.key)

    $scope.isMember = ->
      Session.user().membershipFor($scope.group)?

    $scope.canJoinGroup = ->
      AbilityService.canJoinGroup($scope.group)

    $scope.canRequestMembership = ->
      AbilityService.canRequestMembership($scope.group)

    $scope.hasRequestedMembership = ->
      $scope.group.hasPendingMembershipRequestFrom(Session.user())

    $scope.askToJoinText = ->
      if $scope.hasRequestedMembership()
        'join_group_button.membership_requested'
      else
        'join_group_button.ask_to_join_group'

    $scope.joinGroup = ->
      if AbilityService.isLoggedIn()
        Records.memberships.joinGroup($scope.group).then ->
          EventBus.broadcast $rootScope, 'joinedGroup'
          FlashService.success('join_group_button.messages.joined_group', group: $scope.group.fullName)
      else
        ModalService.open 'AuthModal'

    $scope.requestToJoinGroup = ->
      if AbilityService.isLoggedIn()
        ModalService.open 'MembershipRequestForm', group: -> $scope.group
      else
        ModalService.open 'AuthModal'

    $scope.isLoggedIn = ->
      AbilityService.isLoggedIn()
  ]
]
