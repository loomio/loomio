angular.module('loomioApp').directive 'uploadPhotoButton', ->
  scope: {photo: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/upload_photo_button/upload_photo_button.html'
  replace: true
  controller: (ModalService, StartGroupForm) ->
    openUploadModal: ->
