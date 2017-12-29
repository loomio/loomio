AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ listenForTranslations } = require 'angular/helpers/listen.coffee'

angular.module('loomioApp').directive 'stanceCreated', ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/stance_created.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.actions = [
      name: 'translate_stance'
      icon: 'mdi-translate'
      canPerform: -> $scope.eventable.reason && AbilityService.canTranslate($scope.eventable)  && !$scope.translation
      perform:    -> $scope.eventable.translate()
    ,
      name: 'edit_stance'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditStance($scope.eventable)
      perform:    -> ModalService.open 'PollCommonEditVoteModal', stance: -> $scope.eventable
    ]

    listenForTranslations($scope)
  ]
