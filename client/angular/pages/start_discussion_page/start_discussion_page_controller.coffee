Records       = require 'shared/services/records'
ModalService  = require 'shared/services/modal_service'
LmoUrlService = require 'shared/services/lmo_url_service'

{ applyDiscussionStartSequence } = require 'shared/helpers/apply'
{ listenForLoading }             = require 'shared/helpers/listen'

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
