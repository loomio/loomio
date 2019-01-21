AppConfig      = require 'shared/services/app_config'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'

angular.module('loomioApp').directive 'installMicrosoftCard', ->
  scope: {group: '='}
  templateUrl: 'generated/components/install_microsoft/card/install_microsoft_card.html'
  controller: ['$scope', ($scope) ->
    $scope.show = ->
      AppConfig.features.app.show_microsoft_card &&
      AbilityService.canAdministerGroup($scope.group)

    $scope.groupIdentity = ->
      $scope.group.groupIdentityFor('microsoft')

    $scope.install = ->
      ModalService.open 'InstallMicrosoftModal', group: -> $scope.group

    $scope.canRemoveIdentity = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.remove = ->
      ModalService.open 'ConfirmModal', confirm: ->
        submit:     $scope.groupIdentity().destroy
        text:
          title:    'install_microsoft.card.confirm_remove_title'
          helptext: 'install_microsoft.card.confirm_remove_helptext'
          flash:    'install_microsoft.card.identity_removed'
  ]
