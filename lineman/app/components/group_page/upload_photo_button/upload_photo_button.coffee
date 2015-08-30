angular.module('loomioApp').directive 'uploadPhotoButton', ->
  scope: {group: '=', for: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/upload_photo_button/upload_photo_button.html'
  replace: true
  controller: ($scope, ModalService, CoverPhotoForm, LogoPhotoForm) ->

    $scope.photoType = ->
      switch $scope.for
        when 'cover' then CoverPhotoForm
        when 'logo'  then LogoPhotoForm

    $scope.openUploadModal = ->
      ModalService.open $scope.photoType(), group: -> $scope.group
