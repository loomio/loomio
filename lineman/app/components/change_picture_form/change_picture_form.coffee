angular.module('loomioApp').factory 'ChangePictureForm', ->
  templateUrl: 'generated/components/change_picture_form/change_picture_form.html'
  controller: ($scope, $timeout, CurrentUser, Records, FlashService, UploadService) ->
    $scope.user = CurrentUser.clone()

    $scope.submit = (kind) ->
      $scope.user.avatarKind = kind
      Records.users.updateProfile($scope.user).then changePictureSuccess

    $scope.selectFile = ->
      $timeout -> angular.element('.change-picture-form__file-input').click()

    $scope.upload = (files) ->
      UploadService.upload(files, Records.users.uploadAvatar, 'profile_page.messages.picture_changed', $scope.$close)
