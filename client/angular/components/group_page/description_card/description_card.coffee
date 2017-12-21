angular.module('loomioApp').directive 'descriptionCard', (Records, ModalService, FormService, AbilityService, DocumentModal)->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/description_card/description_card.html'
  replace: true
  controller: ($scope) ->
    $scope.disableEditor = -> $scope.editorEnabled = false

    $scope.canAdministerGroup = ->
      AbilityService.canAdministerGroup($scope.group)

    $scope.save = FormService.submit $scope, $scope.group,
      drafts: true
      prepareFn: -> $scope.group.description = $scope.buh.editableDescription
      flashSuccess: 'description_card.messages.description_updated'
      successCallback: $scope.disableEditor

    $scope.actions = [
      name: 'edit_group'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditGroup($scope.group)
      perform:    ->
        $scope.editorEnabled = true
        $scope.buh = {editableDescription: $scope.group.description}
    ,
      name: 'add_resource'
      icon: 'mdi-attachment'
      canPerform: -> AbilityService.canAdministerGroup($scope.group)
      perform:    -> ModalService.open DocumentModal, doc: ->
        Records.documents.build
          modelId:   $scope.group.id
          modelType: 'Group'
    ]
