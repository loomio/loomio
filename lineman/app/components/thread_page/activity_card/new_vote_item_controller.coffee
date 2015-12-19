angular.module('loomioApp').controller 'NewVoteItemController', ($scope, TranslationService) ->
  vote = $scope.event.vote()
  $scope.vote = vote

  TranslationService.listenForTranslations($scope)
