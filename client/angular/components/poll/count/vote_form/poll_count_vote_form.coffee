AppConfig = require 'shared/services/app_config.coffee'
Records   = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'pollCountVoteForm', (PollService, KeyEventService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/count/vote_form/poll_count_vote_form.html'
  controller: ($scope) ->
    $scope.submit = PollService.submitStance $scope, $scope.stance,
      prepareFn: (optionName) ->
        option = PollService.optionByName($scope.stance.poll(), optionName)
        $scope.$emit 'processing'
        $scope.stance.stanceChoicesAttributes = [poll_option_id: option.id]

    $scope.yesColor = AppConfig.pollColors.count[0]
    $scope.noColor  = AppConfig.pollColors.count[1]

    KeyEventService.submitOnEnter($scope)
