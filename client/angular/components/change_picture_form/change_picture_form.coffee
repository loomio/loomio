Session  = require 'shared/services/session'
Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

{ submitForm, uploadForm } = require 'shared/helpers/form'

angular.module('loomioApp').factory 'ChangePictureForm', ['$rootScope', '$timeout', ($rootScope, $timeout) ->
  templateUrl: 'generated/components/change_picture_form/change_picture_form.html'
  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.user = Session.user().clone()

    $scope.selectFile = ->
      $timeout -> document.querySelector('.change-picture-form__file-input').click()

    $scope.submit = submitForm $scope, $scope.user,
      flashSuccess: 'profile_page.messages.picture_changed'
      submitFn:     Records.users.updateProfile
      prepareFn:    (kind) -> $scope.user.avatarKind = kind
      cleanupFn:    -> EventBus.broadcast $rootScope, 'updateProfile'

    uploadForm $scope, $element, $scope.user,
      flashSuccess:   'profile_page.messages.picture_changed'
      submitFn:       Records.users.uploadAvatar
      cleanupFn:      -> EventBus.broadcast $rootScope, 'updateProfile'
  ]
]
