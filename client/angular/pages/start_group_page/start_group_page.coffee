Records       = require 'shared/services/records.coffee'
EventBus      = require 'shared/services/event_bus.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'
ModalService  = require 'shared/services/modal_service.coffee'

$controller = ($scope, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { page: 'startGroupPage', skipScroll: true }

  @group = Records.groups.build
    name: LmoUrlService.params().name
    customFields:
      pending_emails: _.compact((LmoUrlService.params().pending_emails || "").split(','))

  EventBus.listen $scope, 'nextStep', (_, group) ->
    LmoUrlService.goTo LmoUrlService.group(group)
    ModalService.open 'InvitationModal', group: -> group

  return

$controller.$inject = ['$scope', '$rootScope']
angular.module('loomioApp').controller 'StartGroupPageController', $controller
