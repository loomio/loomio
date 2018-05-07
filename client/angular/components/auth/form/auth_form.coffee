{ listenForLoading }    = require 'shared/helpers/listen'
{ getProviderIdentity } = require 'shared/helpers/user'

angular.module('loomioApp').directive 'authForm', ->
  scope: {preventClose: '=', user: '='}
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ['$scope', ($scope) ->
    $scope.loginComplete = ->
      $scope.user.sentLoginLink or $scope.user.sentPasswordLink

    $scope.pendingProviderIdentity = getProviderIdentity()

    listenForLoading $scope
  ]
