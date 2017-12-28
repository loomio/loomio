Session       = require 'shared/services/session.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ hardReload } = require 'shared/helpers/window.coffee'

angular.module('loomioApp').factory 'InstallSlackModal', ($timeout) ->
  templateUrl: 'generated/components/install_slack/modal/install_slack_modal.html'
  controller: ($scope, group, preventClose) ->

    $scope.hasIdentity = Session.user().identityFor('slack')
    $scope.redirect = ->
      LmoUrlService.params('install_slack', true)
      hardReload('/slack/oauth')
    $timeout $scope.redirect, 500 unless $scope.hasIdentity

    $scope.$on '$close', $scope.$close
    $scope.group = group
    $scope.preventClose = preventClose
