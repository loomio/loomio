angular.module('loomioApp').factory 'LogoPhotoForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/group_page/logo_photo_form/logo_photo_form.html'
  controller: ($scope, $rootScope, $timeout, group, Records, FlashService) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.group-logo-modal__file-input').click()

    $scope.upload = (files) ->
      if _.any files
        Records.groups.uploadPhoto(group, files[0], 'logo').then ->
          FlashService.success 'group_logo_modal.upload_success'
          $rootScope.$broadcast 'groupPhotoUploaded'
          $scope.$close()
