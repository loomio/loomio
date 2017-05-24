angular.module('loomioApp').directive 'pollCommonIndexCard', (Records, LoadingService, LmoUrlService) ->
  scope: {model: '=', limit: '@?', viewMoreLink: '@?'}
  templateUrl: 'generated/components/poll/common/index_card/poll_common_index_card.html'
  controller: ($scope) ->
    $scope.fetchRecords = ->
      Records.polls.fetchFor($scope.model, limit: $scope.limit, status: 'inactive')
    LoadingService.applyLoadingFunction $scope, 'fetchRecords'
    $scope.fetchRecords()

    $scope.viewMoreUrl = ->
      "/polls?#{$scope.model.constructor.singular}_key=#{$scope.model.key}&status=inactive"

    $scope.polls = ->
      _.take $scope.model.closedPolls(), ($scope.limit or 50)
