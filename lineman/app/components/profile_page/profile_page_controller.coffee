angular.module('loomioApp').controller 'ProfilePageController', ($rootScope, Records, FlashService, $location, AbilityService, ModalService, ChangePictureForm, ChangePasswordForm, DeactivateUserForm) ->
  @init = ->
    @user = Records.users.find(window.Loomio.currentUserId)
  @init()

  @availableLocales = ->
    window.Loomio.locales

  @submit = ->
    @isDisabled = true
    @user.setErrors()
    Records.users.updateProfile(@user).then =>
      @isDisabled = false
      FlashService.success('profile_page.messages.updated')
      @init()
    , (response) =>
      @isDisabled = false
      if response.status == 422
        @user.setErrors response.data.errors
      else
        $rootScope.$broadcast 'pageError', response

  @changePicture = ->
    ModalService.open ChangePictureForm

  @changePassword = ->
    ModalService.open ChangePasswordForm

  @deactivateUser = ->
    ModalService.open DeactivateUserForm

  @canDeactivateUser = ->
    AbilityService.canDeactivateUser()

  return
