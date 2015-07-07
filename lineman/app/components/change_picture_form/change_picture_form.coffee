angular.module('loomioApp').factory 'ChangePictureForm', ->
  templateUrl: 'generated/components/change_picture_form/change_picture_form.html'
  controller: ($scope, CurrentUser, Records, FlashService) ->
    $scope.user = CurrentUser.clone()

    $scope.submit = (kind) ->
      $scope.user.avatarKind = kind
      Records.users.updateProfile($scope.user).then changePictureSuccess

    $scope.upload = (files) ->
      Records.users.uploadAvatar(files[0]).then changePictureSuccess

    changePictureSuccess = ->
      FlashService.success 'profile_page.messages.picture_changed'
      $scope.$close()
