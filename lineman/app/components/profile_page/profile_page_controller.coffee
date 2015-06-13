angular.module('loomioApp').controller 'ProfilePageController', ($rootScope, CurrentUser, Records) ->
  @user = CurrentUser.clone()

  @savedName = ->
    CurrentUser.name

  @submit = ->
    @isDisabled = true
    @user.save().then -> 
      @isDisabled = false
    , ->
      @isDisabled = false
      $rootScope.$broadcast 'pageError', 'cantUpdateProfile'

  return
