{ uploadForm } = require 'shared/helpers/form'

angular.module('loomioApp').factory 'LogoPhotoForm', ->
  scope: {group: '='}
  templateUrl: 'generated/components/group_page/logo_photo_form/logo_photo_form.html'
  controller: ['$scope', '$element', 'group', ($scope, $element, group) ->
    uploadForm $scope, $element, group,
      submitFn: group.uploadLogo
      flashSuccess: 'logo_photo_form.upload_success'
  ]
