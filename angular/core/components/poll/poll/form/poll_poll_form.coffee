angular.module('loomioApp').directive 'pollPollForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/poll/form/poll_poll_form.html'
  controller: ($scope, PollService, KeyEventService) ->

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.$emit 'processing'
        $scope.$broadcast('addPollOption')

    KeyEventService.submitOnEnter($scope)
