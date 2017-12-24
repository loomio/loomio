{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'pollPollVoteForm', (PollService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/poll/vote_form/poll_poll_vote_form.html'
  controller: ($scope) ->
    $scope.vars = {}
    $scope.pollOptionIdsChecked = {}

    initForm = do ->
      if $scope.stance.poll().multipleChoice
        $scope.pollOptionIdsChecked = _.fromPairs _.map $scope.stance.stanceChoices(), (choice) ->
          [choice.pollOptionId, true]
      else
        $scope.vars.pollOptionId = $scope.stance.pollOptionId()

    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: ->
        $scope.$emit 'processing'
        selectedOptionIds = if $scope.stance.poll().multipleChoice
          _.compact(_.map($scope.pollOptionIdsChecked, (v,k) -> parseInt(k) if v))
        else
          [$scope.vars.pollOptionId]

        if _.any selectedOptionIds
          $scope.stance.stanceChoicesAttributes =
            _.map selectedOptionIds, (id) -> {poll_option_id: id}

    submitOnEnter($scope)
