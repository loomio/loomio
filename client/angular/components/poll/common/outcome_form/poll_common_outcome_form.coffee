{ listenForLoading } = require 'angular/helpers/listen.coffee'
{ submitOnEnter }    = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'pollCommonOutcomeForm', ($translate, PollService) ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/outcome_form/poll_common_outcome_form.html'
  controller: ($scope) ->
    $scope.outcome.makeAnnouncement = $scope.outcome.isNew()

    $scope.submit = PollService.submitOutcome $scope, $scope.outcome

    $scope.datesAsOptions = ->
      PollService.fieldFromTemplate $scope.outcome.poll().pollType, 'dates_as_options'

    submitOnEnter($scope)
    listenForLoading($scope)
