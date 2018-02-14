Session       = require 'shared/services/session.coffee'
Records       = require 'shared/services/records.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'
FlashService  = require 'shared/services/flash_service.coffee'
ModalService  = require 'shared/services/modal_service.coffee'
ThreadService = require 'shared/services/thread_service.coffee'

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
