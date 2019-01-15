{ uploadForm }  = require 'shared/helpers/form'
{ updateCover } = require 'shared/helpers/layout'

angular.module('loomioApp').factory 'CoverPhotoForm', ->
  template: require('./cover_photo_form.haml')
  controller: ['$scope', '$element', 'group', ($scope, $element, group) ->
    uploadForm $scope, $element, group,
      submitFn: group.uploadCover
      flashSuccess: 'cover_photo_form.upload_success'
      successCallback: updateCover
  ]
