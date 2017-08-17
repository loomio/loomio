angular.module('loomioApp').directive 'pollRankedChoiceForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/ranked_choice/form/poll_ranked_choice_form.html'
  controller: ($scope, PollService, KeyEventService) ->

    $scope.poll.customFields.minimum_stance_choices = $scope.poll.customFields.minimum_stance_choices or 3

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.$emit 'processing'
        $scope.$broadcast('addPollOption')

    KeyEventService.submitOnEnter($scope)
