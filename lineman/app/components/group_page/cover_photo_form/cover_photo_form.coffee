angular.module('loomioApp').factory 'CoverPhotoForm', ->
  templateUrl: 'generated/components/group_page/cover_photo_form/cover_photo_form.html'
  controller: ($scope, $rootScope, $timeout, group, Records, FormService) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.group-cover-photo-modal__file-input').click()

    $scope.upload = FormService.upload $scope, group,
      uploadKind:   'cover_photo'
      submitFn:     Records.groups.uploadPhoto
      flashSuccess: 'group_cover_modal.upload_success'
      successCallback: ->
        $rootScope.$broadcast 'groupPhotoUploaded'
