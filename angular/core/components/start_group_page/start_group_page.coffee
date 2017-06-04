angular.module('loomioApp').controller 'StartGroupPageController', ($scope, $location, $rootScope, $routeParams, Records, PollService, ModalService, PollCommonShareModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'startGroupPage', skipScroll: true })

  @init = ->
    @group = Records.groups.build
      name: $location.search().name
      customFields:
        pending_emails: _.compact(($location.search().pending_emails || "").split(','))
  @init()

  $scope.$on 'saveComplete', (event, group) ->
    ModalService.open InvitationModal, poll: -> group

  return
