Records        = require 'shared/services/records.coffee'
Session        = require 'shared/services/session.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ listenForTranslations, listenForReactions } = require 'angular/helpers/listen.coffee'

angular.module('loomioApp').directive 'pollCommonDetailsPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/details_panel/poll_common_details_panel.html'
  controller: ['$scope', ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canReactToPoll($scope.poll)
    ,
      name: 'translate_poll'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.poll) && !$scope.translation
      perform:    -> $scope.poll.translate(Session.user().locale)
    ,
      name: 'add_resource'
      icon: 'mdi-attachment'
      canPerform: -> AbilityService.canAdministerPoll($scope.poll)
      perform:    -> ModalService.open 'DocumentModal', doc: ->
        Records.documents.build
          modelId:   $scope.poll.id
          modelType: 'Poll'
    ,
      name: 'edit_poll'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditPoll($scope.poll)
      perform:    -> ModalService.open 'PollCommonEditModal', poll: -> $scope.poll
    ]

    listenForTranslations($scope)
    listenForReactions($scope, $scope.poll)
  ]
