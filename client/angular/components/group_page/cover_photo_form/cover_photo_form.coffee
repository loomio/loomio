{ uploadForm }  = require 'shared/helpers/form'
{ updateCover } = require 'shared/helpers/layout'

angular.module('loomioApp').factory 'CoverPhotoForm', ->
  templateUrl: 'generated/components/group_page/cover_photo_form/cover_photo_form.html'
  controller: ['$scope', '$element', 'group', ($scope, $element, group) ->
    uploadForm $scope, $element, group,
      submitFn: group.uploadCover
      flashSuccess: 'cover_photo_form.upload_success'
      successCallback: updateCover
  ]
