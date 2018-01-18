Session        = require 'shared/services/session.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'

{ submitForm } = require 'shared/helpers/form.coffee'

angular.module('loomioApp').factory 'LeaveGroupForm', ['$rootScope', ($rootScope) ->
  templateUrl: 'generated/components/leave_group_form/leave_group_form.html'
  controller: ['$scope', 'group', ($scope, group) ->
    $scope.group = group
    $scope.membership = $scope.group.membershipFor(Session.user())

    $scope.submit = submitForm $scope, $scope.group,
      submitFn: $scope.membership.destroy
      flashSuccess: 'group_page.messages.leave_group_success'
      successCallback: ->
        EventBus.broadcast $rootScope, 'currentUserMembershipsLoaded'
        LmoUrlService.goTo '/dashboard'

    $scope.canLeaveGroup = ->
      AbilityService.canRemoveMembership($scope.membership)
  ]
]
