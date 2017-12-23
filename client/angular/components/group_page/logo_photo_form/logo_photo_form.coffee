Records = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'LogoPhotoForm', ($timeout, FormService) ->
  scope: {group: '='}
  templateUrl: 'generated/components/group_page/logo_photo_form/logo_photo_form.html'
  controller: ($scope, group) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.logo-photo-form__file-input').click()

    $scope.upload = FormService.upload $scope, group,
      uploadKind:     'logo'
      submitFn:       group.uploadPhoto
      loadingMessage: 'common.action.uploading'
      flashSuccess:   'logo_photo_form.upload_success'
