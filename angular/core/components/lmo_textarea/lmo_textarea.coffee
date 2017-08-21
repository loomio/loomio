angular.module('loomioApp').directive 'lmoTextarea', (EmojiService, AttachmentService, MentionService) ->
  scope: {model: '=', field: '@', label: '=?', placeholder: '=?', helptext: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/lmo_textarea/lmo_textarea.html'
  replace: true
  controller: ($scope, $element) ->
    $scope.init = (model) ->
      $scope.model = model
      EmojiService.listen $scope, $scope.model, $scope.field, $element
      MentionService.applyMentions $scope, $scope.model
      AttachmentService.listenForAttachments $scope, $scope.model
      AttachmentService.listenForPaste $scope
    $scope.init($scope.model)
    $scope.$on 'reinitializeForm', (_, model) -> $scope.init(model)
