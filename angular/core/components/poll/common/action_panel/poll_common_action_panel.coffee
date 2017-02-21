angular.module('loomioApp').directive 'pollCommonActionPanel', ($location, ModalService, Records, PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/action_panel/poll_common_action_panel.html'
  controller: ($scope, Records, Session) ->

    $scope.init = ->
      $scope.stance = $scope.poll.stanceFor(Session.user()) or
                      Records.stances.build(pollId: $scope.poll.id).choose($location.search().poll_option_id)
    $scope.$on 'refreshStance', $scope.init
    $scope.init()

    $scope.userHasVoted = ->
      $scope.poll.stanceFor(Session.user())

    $scope.stanceForm = ->
      PollService.formFor($scope.poll.pollType, 'stance')

    $scope.openStanceForm = ->
      ModalService.open $scope.stanceForm(), stance: -> $scope.stance
