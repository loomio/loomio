LmoUrlService = require 'shared/services/lmo_url_service.coffee'

angular.module('loomioApp').directive 'pollCommonIndexCard', ($location, Records, LoadingService) ->
  scope: {model: '=', limit: '@?', viewMoreLink: '=?'}
  templateUrl: 'generated/components/poll/common/index_card/poll_common_index_card.html'
  replace: true
  controller: ($scope) ->
    $scope.fetchRecords = ->
      Records.polls.fetchFor($scope.model, limit: $scope.limit, status: 'closed')
    LoadingService.applyLoadingFunction $scope, 'fetchRecords'
    $scope.fetchRecords()

    $scope.displayViewMore = ->
      $scope.viewMoreLink and
      $scope.model.closedPollsCount > $scope.polls().length

    $scope.viewMore = ->
      opts = {}
      opts["#{$scope.model.constructor.singular}_key"] = $scope.model.key
      opts["status"] = "closed"
      $location.path('polls').search(opts)

    $scope.polls = ->
      _.take $scope.model.closedPolls(), ($scope.limit or 50)
