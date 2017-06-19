angular.module('loomioApp').directive 'pollCommonStartPoll', ($window, Records, PollService, LmoUrlService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/start_poll/poll_common_start_poll.html'
  controller: ($scope) ->
    $scope.currentStep = if $scope.poll.pollType then 'save' else 'choose'
    $scope.$on 'chooseComplete',  -> $scope.currentStep = 'save';   $scope.isDisabled = false
    $scope.$on 'saveBack',        -> $scope.currentStep = 'choose'; $scope.isDisabled = false
    $scope.poll.makeAnnouncement = $scope.poll.isNew()

    $scope.$on 'saveComplete', (event, poll) ->
      if poll.group()
        $scope.$emit '$close'
      else
        $scope.poll = poll
        $scope.currentStep = 'share'
      $scope.isDisabled = false
