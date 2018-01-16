EventBus = require 'shared/services/event_bus.coffee'

{ listenForLoading } = require 'shared/helpers/listen.coffee'
{ iconFor }          = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').factory 'PollCommonEditVoteModal', ['$rootScope', ($rootScope) ->
  templateUrl: 'generated/components/poll/common/edit_vote_modal/poll_common_edit_vote_modal.html'
  controller: ['$scope', 'stance', ($scope, stance) ->
    $scope.stance = stance.clone()

    EventBus.listen $scope, 'stanceSaved', ->
      $scope.$close()
      EventBus.broadcast $rootScope, 'refreshStance'

    $scope.icon = ->
      iconFor($scope.stance.poll())

    listenForLoading $scope
  ]
]
