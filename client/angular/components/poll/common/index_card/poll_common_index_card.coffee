Records       = require 'shared/services/records'
LmoUrlService = require 'shared/services/lmo_url_service'

{ applyLoadingFunction } = require 'shared/helpers/apply'

angular.module('loomioApp').directive 'pollCommonIndexCard', ->
  scope: {model: '=', limit: '@?', viewMoreLink: '=?'}
  templateUrl: 'generated/components/poll/common/index_card/poll_common_index_card.html'
  replace: false
  controller: ['$scope', ($scope) ->
    $scope.fetchRecords = ->
      Records.polls.fetchFor($scope.model, limit: $scope.limit, status: 'closed')
    applyLoadingFunction($scope, 'fetchRecords')
    $scope.fetchRecords()

    $scope.displayViewMore = ->
      $scope.viewMoreLink and
      $scope.model.closedPollsCount > $scope.polls().length

    $scope.viewMore = ->
      LmoUrlService.goTo('polls')
      LmoUrlService.params("#{$scope.model.constructor.singular}_key", $scope.model.key)
      LmoUrlService.params('status', 'closed')

    $scope.polls = ->
      _.take $scope.model.closedPolls(), ($scope.limit or 50)
  ]
