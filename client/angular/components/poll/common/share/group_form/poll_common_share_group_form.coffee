Session        = require 'shared/services/session.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

{ submitPoll } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').directive 'pollCommonShareGroupForm', ['$rootScope', ($rootScope) ->
  scope: {poll: '='}
  restrict: 'E'
  templateUrl: 'generated/components/poll/common/share/group_form/poll_common_share_group_form.html'
  controller: ['$scope', ($scope) ->
    $scope.groupId = $scope.poll.groupId

    $scope.submit = submitPoll $scope, $scope.poll,
      broadcaster: $rootScope
      flashSuccess: 'poll_common_share_form.group_set'
      successCallback: -> $scope.groupId = $scope.poll.groupId

    $scope.groups = ->
      _.filter Session.user().groups(), (group) ->
        AbilityService.canStartPoll(group)
  ]
]
