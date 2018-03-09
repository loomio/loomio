{ listenForLoading }    = require 'shared/helpers/listen.coffee'
{ getProviderIdentity } = require 'shared/helpers/user.coffee'

angular.module('loomioApp').directive 'authForm', ->
  scope: {preventClose: '=', user: '='}
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ['$scope', ($scope) ->
    $scope.loginComplete = ->
      $scope.user.sentLoginLink or $scope.user.sentPasswordLink

    $scope.pendingProviderIdentity = getProviderIdentity()

    listenForLoading $scope
  ]
