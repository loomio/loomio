angular.module('loomioApp').factory 'LogoPhotoForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/group_page/logo_photo_form/logo_photo_form.html'
  controller: ($scope, $timeout, group, Records, FormService) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.group-logo-modal__file-input').click()

    $scope.upload = FormService.upload $scope, group,
      uploadKind:   'logo'
      submitFn:     Records.groups.uploadPhoto
      flashSuccess: 'group_logo_modal.upload_success'
