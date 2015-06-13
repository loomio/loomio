angular.module('loomioApp').controller 'ProfilePageController', ($rootScope, CurrentUser, Records) ->
  @user = CurrentUser.clone()

  @availableLocales = ->
    window.Loomio.locales

  @submit = ->
    @isDisabled = true
    @user.save().then -> 
      @isDisabled = false
    , ->
      @isDisabled = false
      $rootScope.$broadcast 'pageError', 'cantUpdateProfile'

  return
