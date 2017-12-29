Session = require 'shared/services/session.coffee'
Records = require 'shared/services/records.coffee'

{ submitForm, upload } = require 'angular/helpers/form.coffee'

angular.module('loomioApp').factory 'ChangePictureForm', ['$rootScope', '$timeout', ($rootScope, $timeout) ->
  templateUrl: 'generated/components/change_picture_form/change_picture_form.html'
  controller: ['$scope', ($scope) ->
    $scope.user = Session.user().clone()

    $scope.selectFile = ->
      $timeout -> document.querySelector('.change-picture-form__file-input').click()

    $scope.submit = submitForm $scope, $scope.user,
      flashSuccess: 'profile_page.messages.picture_changed'
      submitFn:     Records.users.updateProfile
      prepareFn:    (kind) -> $scope.user.avatarKind = kind
      cleanupFn:    -> $rootScope.$broadcast 'updateProfile'

    $scope.upload = upload $scope, $scope.user,
      flashSuccess:   'profile_page.messages.picture_changed'
      submitFn:       Records.users.uploadAvatar
      loadingMessage: 'common.action.uploading'
      cleanupFn:      -> $rootScope.$broadcast 'updateProfile'
  ]
]
