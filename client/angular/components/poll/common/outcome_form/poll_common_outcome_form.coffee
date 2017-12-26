{ listenForLoading }  = require 'angular/helpers/listen.coffee'
{ submitOnEnter }     = require 'angular/helpers/keyboard.coffee'
{ submitOutcome }     = require 'angular/helpers/form.coffee'
{ fieldFromTemplate } = require 'angular/helpers/poll.coffee'

angular.module('loomioApp').directive 'pollCommonOutcomeForm', ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/outcome_form/poll_common_outcome_form.html'
  controller: ($scope) ->
    $scope.outcome.makeAnnouncement = $scope.outcome.isNew()

    $scope.submit = submitOutcome $scope, $scope.outcome

    $scope.datesAsOptions = ->
      fieldFromTemplate $scope.outcome.poll().pollType, 'dates_as_options'

    submitOnEnter($scope)
    listenForLoading($scope)
