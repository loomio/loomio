angular.module('loomioApp').factory 'ChangePictureForm', ->
  templateUrl: 'generated/components/change_picture_form/change_picture_form.html'
  controller: ($scope, $timeout, User, Records, FormService) ->
    $scope.user = User.current().clone()

    $scope.selectFile = ->
      $timeout -> document.querySelector('.change-picture-form__file-input').click()

    $scope.submit = FormService.submit $scope, $scope.user,
      flashSuccess: 'profile_page.messages.picture_changed'
      submitFn:     Records.users.updateProfile
      prepareFn:    (kind) -> $scope.user.avatarKind = kind

    $scope.upload = FormService.upload $scope, $scope.user,
      flashSuccess:   'profile_page.messages.picture_changed'
      submitFn:       Records.users.uploadAvatar
      loadingMessage: 'common.action.uploading'
