angular.module('loomioApp').factory 'ChangePictureForm', ->
  templateUrl: 'generated/components/change_picture_form/change_picture_form.html'
  controller: ($scope, CurrentUser, Records, FlashService) ->
    $scope.user = CurrentUser.clone()

    $scope.submit = (kind) ->
      $scope.user.avatarKind = kind
      Records.users.updateProfile($scope.user).then ->
        FlashService.success 'profile_page.messages.picture_changed'
        $scope.$close()

    $scope.upload = (files) ->
      $scope.user.uploadedAvatar = files[0]
      if $scope.user.uploadedAvatar?
        $scope.submit('uploaded')
