Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ listenForTranslations, performTranslation } = require 'angular/helpers/translation.coffee'
{ listenForReactions }    = require 'angular/helpers/emoji.coffee'

angular.module('loomioApp').directive 'pollCommonDetailsPanel', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/details_panel/poll_common_details_panel.html'
  controller: ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canReactToPoll($scope.poll)
    ,
      name: 'translate_poll'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.poll) && !$scope.translation
      perform:    -> performTranslation($scope, $scope.poll)
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
