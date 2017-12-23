LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ listenForLoading } = require 'angular/helpers/loading.coffee'
{ applySequence }    = require 'angular/helpers/sequence.coffee'

angular.module('loomioApp').directive 'installSlackForm', (FormService) ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/form/install_slack_form.html'
  controller: ($scope) ->

    applySequence $scope,
      steps:           ['install', 'invite', 'decide']
      initialStep:     if $scope.group then 'invite' else 'install'
      installComplete: (_, group) -> $scope.group = group

    listenForLoading $scope
