angular.module('loomioApp').config ($facebookProvider) ->
  $facebookProvider.setAppId window.Loomio.oauthProviders.facebook || '1198254923601207'
  $facebookProvider.setPermissions('user_managed_groups')
  $facebookProvider.setVersion('v2.8')
