Records       = require 'shared/services/records.coffee'
ModalService  = require 'shared/services/modal_service.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ listenForLoading } = require 'shared/helpers/listen.coffee'

$controller = ($rootScope) ->
  $rootScope.$broadcast('currentComponent', { page: 'startDiscussionPage', skipScroll: true })
  @discussion = Records.discussions.build
    title:       LmoUrlService.params().title
    groupId:     LmoUrlService.params().group_id

  listenForLoading $scope

  $scope.$on 'nextStep', (_, discussion) ->
    ModalService.open 'AnnouncementModal', announcement: ->
      Records.announcements.buildFromModel(discussion, 'new_discussion')

  return

$controller.$inject = ['$rootScope']
angular.module('loomioApp').controller 'StartDiscussionPageController', $controller
