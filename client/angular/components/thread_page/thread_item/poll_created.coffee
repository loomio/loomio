Session        = require 'shared/services/session.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ listenForTranslations, listenForReactions } = require 'shared/helpers/listen.coffee'

angular.module('loomioApp').directive 'pollCreated', ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/outcome_created.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.actions = [
      name: 'react'
      canPerform: -> AbilityService.canReactToPoll($scope.eventable.poll())
    ,
      name: 'edit_poll'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditPoll($scope.eventable)
      perform:    -> ModalService.open 'PollCommonEditModal', poll: -> $scope.eventable
    ,
      name: 'translate_outcome'
      icon: 'mdi-translate'
      canPerform: -> AbilityService.canTranslate($scope.eventable)
      perform:    -> $scope.eventable.translate(Session.user().locale)
    ]

    listenForReactions $scope, $scope.eventable
    listenForTranslations $scope
  ]
