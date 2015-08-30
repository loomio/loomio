angular.module('loomioApp').factory 'LogoPhotoForm', ->
  templateUrl: 'generated/components/group_page/logo_photo_form/logo_photo_form.html'
  controller: ($scope, $timeout) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.group-logo-modal__file-input').click()

    $scope.upload = (files) ->
      if _.any files
        Records.groups.uploadLogo($scope.group, files[0]).then ->
          FlashService.success 'group_logo_modal.upload_success'
          $scope.$close()
