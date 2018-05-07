LmoUrlService = require 'shared/services/lmo_url_service'

{ listenForLoading } = require 'shared/helpers/listen'
{ applySequence }    = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'installSlackForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/form/install_slack_form.html'
  controller: ['$scope', ($scope) ->

    applySequence $scope,
      steps:           ['install', 'invite', 'decide']
      initialStep:     if $scope.group then 'invite' else 'install'
      installComplete: (_, group) -> $scope.group = group

    listenForLoading $scope
  ]
