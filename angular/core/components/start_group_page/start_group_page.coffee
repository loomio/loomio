angular.module('loomioApp').controller 'StartGroupPageController', ($scope, $location, $rootScope, Records, ModalService, InvitationModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'startGroupPage', skipScroll: true })

  @group = Records.groups.build
    name: $location.search().name
    customFields:
      pending_emails: _.compact(($location.search().pending_emails || "").split(','))

  $scope.$on 'nextStep', (_, group) ->
    ModalService.open InvitationModal, group: -> group

  return
