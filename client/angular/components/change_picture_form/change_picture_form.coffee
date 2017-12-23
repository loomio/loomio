Session = require 'shared/services/session.coffee'
Records = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'ChangePictureForm', ($timeout, FormService) ->
  templateUrl: 'generated/components/change_picture_form/change_picture_form.html'
  controller: ($scope, $rootScope) ->
    $scope.user = Session.user().clone()

    $scope.selectFile = ->
      $timeout -> document.querySelector('.change-picture-form__file-input').click()

    $scope.submit = FormService.submit $scope, $scope.user,
      flashSuccess: 'profile_page.messages.picture_changed'
      submitFn:     Records.users.updateProfile
      prepareFn:    (kind) -> $scope.user.avatarKind = kind
      cleanupFn:    -> $rootScope.$broadcast 'updateProfile'

    $scope.upload = FormService.upload $scope, $scope.user,
      flashSuccess:   'profile_page.messages.picture_changed'
      submitFn:       Records.users.uploadAvatar
      loadingMessage: 'common.action.uploading'
      cleanupFn:      -> $rootScope.$broadcast 'updateProfile'
