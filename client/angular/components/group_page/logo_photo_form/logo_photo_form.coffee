Records = require 'shared/services/records.coffee'

{ upload } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'LogoPhotoForm', ($timeout) ->
  scope: {group: '='}
  templateUrl: 'generated/components/group_page/logo_photo_form/logo_photo_form.html'
  controller: ($scope, group) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.logo-photo-form__file-input').click()

    $scope.upload = upload $scope, group,
      uploadKind:     'logo'
      submitFn:       group.uploadPhoto
      loadingMessage: 'common.action.uploading'
      flashSuccess:   'logo_photo_form.upload_success'
