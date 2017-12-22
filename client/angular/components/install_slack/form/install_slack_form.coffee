LmoUrlService = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').directive 'installSlackForm', (FormService, SequenceService, Session, Records, LoadingService)->
  scope: {group: '='}
  templateUrl: 'generated/components/install_slack/form/install_slack_form.html'
  controller: ($scope) ->

    SequenceService.applySequence $scope,
      steps:           ['install', 'invite', 'decide']
      initialStep:     if $scope.group then 'invite' else 'install'
      installComplete: (_, group) -> $scope.group = group

    LoadingService.listenForLoading $scope
