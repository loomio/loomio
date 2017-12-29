{ listenForLoading } = require 'angular/helpers/listen.coffee'

angular.module('loomioApp').factory 'PollCommonAddOptionModal', ->
  templateUrl: 'generated/components/poll/common/add_option/modal/poll_common_add_option_modal.html'
  controller: ['$scope', 'poll', ($scope, poll) ->
    $scope.poll = poll.clone()

    $scope.$on '$close', $scope.$close
    listenForLoading $scope
  ]
