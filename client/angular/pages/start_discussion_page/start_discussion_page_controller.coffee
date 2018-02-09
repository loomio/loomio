Records       = require 'shared/services/records.coffee'
ModalService  = require 'shared/services/modal_service.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ applyDiscussionStartSequence } = require 'shared/helpers/apply.coffee'
{ listenForLoading }             = require 'shared/helpers/listen.coffee'

$controller = ($scope, $rootScope) ->
  $rootScope.$broadcast('currentComponent', { page: 'startDiscussionPage', skipScroll: true })
  @discussion = Records.discussions.build
    title:       LmoUrlService.params().title
    groupId:     LmoUrlService.params().group_id

  listenForLoading $scope

  applyDiscussionStartSequence @,
    emitter: $scope
    afterSaveComplete: (event) ->
      ModalService.open 'AnnouncementModal', announcement: ->
        Records.announcements.buildFromModel(event)

  return

$controller.$inject = ['$scope', '$rootScope']
angular.module('loomioApp').controller 'StartDiscussionPageController', $controller
