Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'

{ upload } = require 'shared/helpers/form.coffee'

angular.module('loomioApp').factory 'CoverPhotoForm', ['$timeout', '$rootScope', ($timeout, $rootScope) ->
  templateUrl: 'generated/components/group_page/cover_photo_form/cover_photo_form.html'
  controller: ['$scope', 'group', ($scope, group) ->

    $scope.selectFile = ->
      $timeout -> document.querySelector('.cover-photo-form__file-input').click()

    $scope.upload = upload $scope, group,
      uploadKind:     'cover_photo'
      submitFn:       group.uploadPhoto
      loadingMessage: 'common.action.uploading'
      successCallback: (data) ->
        EventBus.broadcast $rootScope, 'setBackgroundImageUrl', group
      flashSuccess:   'cover_photo_form.upload_success'
  ]
]
