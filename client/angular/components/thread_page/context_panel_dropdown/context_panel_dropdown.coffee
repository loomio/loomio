EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
ThreadService  = require 'shared/services/thread_service'
LmoUrlService  = require 'shared/services/lmo_url_service'

angular.module('loomioApp').directive 'contextPanelDropdown', ['$rootScope', ($rootScope) ->
  scope: {discussion: '='}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/thread_page/context_panel_dropdown/context_panel_dropdown.html'
  controller: ['$scope', ($scope) ->

    $scope.canChangeVolume = ->
      AbilityService.canChangeVolume($scope.discussion)

    $scope.openChangeVolumeForm = ->
      ModalService.open 'ChangeVolumeForm', model: => $scope.discussion

    $scope.canEditThread = ->
      AbilityService.canEditThread($scope.discussion)

    $scope.canMuteThread = ->
      AbilityService.isLoggedIn()

    $scope.editThread = ->
      ModalService.open 'DiscussionEditModal', discussion: => $scope.discussion

    $scope.canPinThread = ->
      AbilityService.canPinThread($scope.discussion)

    $scope.closeThread = ->
      ThreadService.close($scope.discussion)

    $scope.reopenThread = ->
      ThreadService.reopen($scope.discussion)

    $scope.pinThread = ->
      ThreadService.pin($scope.discussion)

    $scope.unpinThread = ->
      ThreadService.unpin($scope.discussion)

    $scope.muteThread = ->
      ThreadService.mute($scope.discussion)

    $scope.unmuteThread = ->
      ThreadService.unmute($scope.discussion)

    $scope.canMoveThread = ->
      AbilityService.canMoveThread($scope.discussion)

    $scope.canCloseThread = ->
      AbilityService.canCloseThread($scope.discussion)

    $scope.moveThread = ->
      ModalService.open 'MoveThreadForm', discussion: => $scope.discussion

    $scope.requestPagePrinted = ->
      EventBus.broadcast $rootScope, 'toggleSidebar', false
      EventBus.broadcast $rootScope, 'fetchRecordsForPrint'

    $scope.canDeleteThread = ->
      AbilityService.canDeleteThread($scope.discussion)

    $scope.deleteThread = ->
      ModalService.open 'ConfirmModal', confirm: ->
        submit:     $scope.discussion.destroy
        text:
          title:    'delete_thread_form.title'
          helptext: 'delete_thread_form.body'
          submit:   'delete_thread_form.confirm'
          flash:    'delete_thread_form.messages.success'
        redirect:   LmoUrlService.group $scope.discussion.group()
  ]
]
