{ iconFor } = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').factory 'PollCommonEditModal', ->
  templateUrl: 'generated/components/poll/common/edit_modal/poll_common_edit_modal.html'
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()
    $scope.poll.makeAnnouncement = $scope.poll.isNew()

    $scope.icon = ->
      iconFor($scope.poll)

    $scope.$on 'nextStep', $scope.$close
  ]
