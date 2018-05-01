Records        = require 'shared/services/records.coffee'
Session        = require 'shared/services/session.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'
FlashService   = require 'shared/services/flash_service.coffee'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen.coffee'

angular.module('loomioApp').directive 'pollCommonDetailsPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/details_panel/poll_common_details_panel.html'
  controller: ['$scope', 'clipboard', ($scope, clipboard) ->
    $scope.actions = [
      name: 'translate_poll'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.poll)
      perform:    -> $scope.poll.translate(Session.user().locale)
    ,
      name: 'announce_poll'
      icon: 'mdi-account-plus'
      canPerform: -> AbilityService.canAdministerPoll($scope.poll)
      perform:    -> ModalService.open 'AnnouncementModal', announcement: ->
        Records.announcements.buildFromModel($scope.poll)
    ,
    #   name: 'add_resource'
    #   icon: 'mdi-attachment'
    #   canPerform: -> AbilityService.canAdministerPoll($scope.poll)
    #   perform:    -> ModalService.open 'DocumentModal', doc: ->
    #     Records.documents.build
    #       modelId:   $scope.poll.id
    #       modelType: 'Poll'
    # ,
    #   name: 'copy_url'
    #   icon: 'mdi-link'
    #   canPerform: -> clipboard.supported
    #   perform:    ->
    #     clipboard.copyText(LmoUrlService.poll($scope.poll, {}, absolute: true))
    #     FlashService.success("action_dock.poll_copied")
    # ,
      name: 'edit_poll'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditPoll($scope.poll)
      perform:    -> ModalService.open 'PollCommonEditModal', poll: -> $scope.poll
    ]

    listenForTranslations($scope)
    listenForReactions($scope, $scope.poll)
  ]
