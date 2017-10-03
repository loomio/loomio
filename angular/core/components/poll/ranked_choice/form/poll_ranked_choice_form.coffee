angular.module('loomioApp').directive 'pollRankedChoiceForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/ranked_choice/form/poll_ranked_choice_form.html'
  controller: ($scope, PollService, KeyEventService) ->

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.$emit 'processing'
        $scope.$broadcast('addPollOption')

    setMinimumStanceChoices = ->
      return unless $scope.poll.isNew()
      $scope.poll.customFields.minimum_stance_choices =
        _.max [$scope.poll.pollOptionNames.length, 1]
    setMinimumStanceChoices()
    $scope.$on 'pollOptionsChanged', setMinimumStanceChoices

    KeyEventService.submitOnEnter($scope)
