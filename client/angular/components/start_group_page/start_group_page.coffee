Records       = require 'shared/services/records.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').controller 'StartGroupPageController', ($scope, $location, $rootScope, ModalService, InvitationModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'startGroupPage', skipScroll: true })

  @group = Records.groups.build
    name: $location.search().name
    customFields:
      pending_emails: _.compact(($location.search().pending_emails || "").split(','))

  $scope.$on 'nextStep', (_, group) ->
    $location.path LmoUrlService.group(group)
    ModalService.open InvitationModal, group: -> group

  return
