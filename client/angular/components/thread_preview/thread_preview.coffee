Session       = require 'shared/services/session'
Records       = require 'shared/services/records'
LmoUrlService = require 'shared/services/lmo_url_service'
FlashService  = require 'shared/services/flash_service'
ModalService  = require 'shared/services/modal_service'
ThreadService = require 'shared/services/thread_service'

angular.module('loomioApp').directive 'threadPreview', ->
  scope: {thread: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_preview/thread_preview.html'
  controller: ['$scope', ($scope) ->
    $scope.dismiss      = -> ThreadService.dismiss($scope.thread)
    $scope.muteThread   = -> ThreadService.mute($scope.thread)
    $scope.unmuteThread = -> ThreadService.unmute($scope.thread)

    return
  ]
