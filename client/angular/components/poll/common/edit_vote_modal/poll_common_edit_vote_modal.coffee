EventBus = require 'shared/services/event_bus'

{ listenForLoading } = require 'shared/helpers/listen'
{ iconFor }          = require 'shared/helpers/poll'
{ submitStance }  = require 'shared/helpers/form'

angular.module('loomioApp').factory 'PollCommonEditVoteModal', ['$rootScope', ($rootScope) ->
  templateUrl: 'generated/components/poll/common/edit_vote_modal/poll_common_edit_vote_modal.html'
  controller: ['$scope', 'stance', ($scope, stance) ->
    $scope.isEditing = true
    $scope.stance = stance.clone()

    $scope.toggleCreation = ->
      $scope.isEditing = false

    EventBus.listen $scope, 'stanceSaved', ->
      $scope.$close()
      EventBus.broadcast $rootScope, 'refreshStance'

    $scope.icon = ->
      iconFor($scope.stance.poll())

    $scope.submit = submitStance $scope, $scope.stance,
      prepareFn: ->
        EventBus.emit $scope, 'processing'

    listenForLoading $scope
  ]
]
