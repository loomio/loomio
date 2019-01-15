{ uploadForm } = require 'shared/helpers/form'

angular.module('loomioApp').factory 'LogoPhotoForm', ->
  scope: {group: '='}
  template: require('./logo_photo_form.haml')
  controller: ['$scope', '$element', 'group', ($scope, $element, group) ->
    uploadForm $scope, $element, group,
      submitFn: group.uploadLogo
      flashSuccess: 'logo_photo_form.upload_success'
  ]
