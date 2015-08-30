angular.module('loomioApp').factory 'CoverPhotoForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/group_page/cover_photo_form/cover_photo_form.html'
  controller: ($scope, $timeout) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.group-cover-photo-modal__file-input').click()

    $scope.upload = (files) ->
      if _.any files
        Records.groups.uploadCoverPhoto($scope.group, files[0]).then ->
          FlashService.success 'group_cover_modal.upload_success'
          $scope.$close()
