angular.module('loomioApp').directive 'authForm', (AppConfig, LoadingService) ->
  scope: {preventClose: '=', user: '='}
  templateUrl: 'generated/components/auth/form/auth_form.html'
  controller: ($scope) ->
    $scope.loginComplete = ->
      $scope.user.sentLoginLink or $scope.user.sentPasswordLink

    if _.contains(_.pluck(AppConfig.identityProviders, 'name'), (AppConfig.pendingIdentity or {}).identity_type)
      $scope.pendingProviderIdentity = AppConfig.pendingIdentity

    LoadService.listenForLoading $scope
