LmoUrlService = require 'shared/services/lmo_url_service'

{ listenForLoading } = require 'shared/helpers/listen'
{ applySequence }    = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'installSlackForm', ->
  scope: {group: '='}
  template: require('./install_slack_form.haml')
  controller: ['$scope', ($scope) ->

    applySequence $scope,
      steps:           ['install', 'invite', 'decide']
      initialStep:     if $scope.group then 'invite' else 'install'
      installComplete: (_, group) -> $scope.group = group

    listenForLoading $scope
  ]
