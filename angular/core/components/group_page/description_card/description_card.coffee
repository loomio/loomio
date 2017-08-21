angular.module('loomioApp').directive 'descriptionCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/description_card/description_card.html'
  replace: true
  controller: ($scope, FormService, AbilityService) ->
    $scope.editorEnabled = false;

    $scope.canEditGroup = ->
      AbilityService.canEditGroup($scope.group)

    $scope.enableEditor = ->
      $scope.editorEnabled = true
      $scope.buh =
        editableDescription: $scope.group.description

    $scope.disableEditor = ->
     $scope.editorEnabled = false

    $scope.save = FormService.submit $scope, $scope.group,
      drafts: true
      prepareFn: -> $scope.group.description = $scope.buh.editableDescription
      flashSuccess: 'description_card.messages.description_updated'
      successCallback: $scope.disableEditor
