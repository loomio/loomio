Records = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'CoverPhotoForm', ($timeout, FormService) ->
  templateUrl: 'generated/components/group_page/cover_photo_form/cover_photo_form.html'
  controller: ($scope, $rootScope, group) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.cover-photo-form__file-input').click()

    $scope.upload = FormService.upload $scope, group,
      uploadKind:     'cover_photo'
      submitFn:       group.uploadPhoto
      loadingMessage: 'common.action.uploading'
      successCallback: (data) ->
        $rootScope.$broadcast('setBackgroundImageUrl', group)
      flashSuccess:   'cover_photo_form.upload_success'
