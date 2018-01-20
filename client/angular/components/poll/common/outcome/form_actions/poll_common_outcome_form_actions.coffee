{ listenForLoading }  = require 'shared/helpers/listen.coffee'
{ submitOnEnter }     = require 'shared/helpers/keyboard.coffee'
{ submitOutcome }     = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'pollCommonOutcomeFormActions', ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/outcome/form_actions/poll_common_outcome_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.outcome.makeAnnouncement = $scope.outcome.isNew()
    $scope.submit = submitOutcome $scope, $scope.outcome

    submitOnEnter($scope)
    listenForLoading($scope)
  ]
