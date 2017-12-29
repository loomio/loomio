{ listenForLoading } = require 'angular/helpers/listen.coffee'
{ iconFor }          = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').factory 'PollCommonEditVoteModal', ['$rootScope', ($rootScope) ->
  templateUrl: 'generated/components/poll/common/edit_vote_modal/poll_common_edit_vote_modal.html'
  controller: ['$scope', 'stance', ($scope, stance) ->
    $scope.stance = stance.clone()

    $scope.$on 'stanceSaved', ->
      $scope.$close()
      $rootScope.$broadcast 'refreshStance'

    $scope.icon = ->
      iconFor($scope.stance.poll())

    listenForLoading $scope
  ]
]
