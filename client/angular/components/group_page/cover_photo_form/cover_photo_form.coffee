Records  = require 'shared/services/records.coffee'

{ upload }      = require 'shared/helpers/form.coffee'
{ updateCover } = require 'shared/helpers/layout.coffee'

angular.module('loomioApp').factory 'CoverPhotoForm', ['$timeout', ($timeout) ->
  templateUrl: 'generated/components/group_page/cover_photo_form/cover_photo_form.html'
  controller: ['$scope', 'group', ($scope, group) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.cover-photo-form input').click()

    $scope.upload = upload $scope, group,
      uploadKind:     'cover_photo'
      submitFn:       group.uploadPhoto
      loadingMessage: 'common.action.uploading'
      flashSuccess:   'cover_photo_form.upload_success'
      successCallback: updateCover
  ]
]
