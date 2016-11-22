angular.module('loomioApp').directive 'descriptionCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/description_card/description_card.html'
  replace: true
  controller: ($scope, FormService) ->
    $scope.editorEnabled = false;
    $scope.showDescriptionPlaceholder = ->
      !$scope.group.description

    $scope.enableEditor = ->
      $scope.editorEnabled = true
      $scope.editableDescription = $scope.group.description

    $scope.disableEditor = ->
     $scope.editorEnabled = false

    $scope.save = ->
      $scope.group.description = $scope.editableDescription
      submitForm().then ->
        $scope.disableEditor()

    submitForm = FormService.submit $scope, $scope.group,
      draftFields: ['description']
