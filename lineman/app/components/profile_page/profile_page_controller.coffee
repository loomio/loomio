angular.module('loomioApp').controller 'ProfilePageController', ($rootScope, CurrentUser, Records, FlashService, $location) ->
  @user = CurrentUser.clone()

  @availableLocales = ->
    window.Loomio.locales

  @submit = ->
    @isDisabled = true
    Records.users.updateProfile(@user).then ->
      @isDisabled = false
      FlashService.success('profile_page.messages.updated')
      $location.path('/dashboard')
    , ->
      @isDisabled = false
      $rootScope.$broadcast 'pageError', 'cantUpdateProfile', @user

  return
