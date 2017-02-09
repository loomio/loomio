angular.module('loomioApp').directive 'pollCommonVotesPanel', (PollService, RecordLoader) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/votes_panel/poll_common_votes_panel.html'
  controller: ($scope) ->
    # sorry. ng-if and md-select break. github.com/angular/material/issues/3940
    $scope.fix = {}
    $scope.sortOptions = PollService.fieldFromTemplate($scope.poll.pollType, 'sort_options')
    $scope.fix.votesOrder = $scope.sortOptions[0]

    $scope.loader = new RecordLoader
      collection: 'stances'
      params:
        poll_id: $scope.poll.key
        order: $scope.fix.votesOrder

    $scope.hasSomeVotes = ->
      $scope.poll.stancesCount > 0

    $scope.moreToLoad = ->
      $scope.loader.numLoaded < $scope.poll.stancesCount

    sortFn =
      newest_first: (stance) ->
        -(stance.createdAt)
      oldest_first: (stance) ->
        stance.createdAt
      priority_first: (stance) ->
        stance.pollOption().priority
      priority_last: (stance) ->
        -(stance.pollOption().priority)

    $scope.stances = ->
      $scope.poll.uniqueStances(sortFn[$scope.fix.votesOrder], $scope.loader.numLoaded)

    $scope.changeOrder = ->
      $scope.loader.reset()
      $scope.loader.params.order = $scope.fix.votesOrder
      $scope.loader.fetchRecords()

    $scope.loader.fetchRecords()
    
    $scope.$on 'refreshStance', ->
      $scope.loader.fetchRecords()
