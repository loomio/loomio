angular.module('loomioApp').directive 'groupPreviousProposalsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_previous_proposals_card/group_previous_proposals_card.html'
  replace: true
  controller: ($scope, Session, Records, AbilityService) ->
    if AbilityService.canViewPreviousProposals($scope.group)
      Records.proposals.fetchClosedByGroup($scope.group.key, per: 3).then ->
        Records.votes.fetchMyVotes($scope.group) if AbilityService.isLoggedIn()

    $scope.showPreviousProposals = ->
      AbilityService.canViewPreviousProposals($scope.group) and $scope.group.hasPreviousProposals()

    $scope.lastVoteByCurrentUser = (proposal) ->
      proposal.lastVoteByUser(Session.user())

    $scope.canShowMore = ->
      $scope.group.closedMotionsCount > 3

angular.module('loomioApp').filter 'cut', ->
  (value, wordwise, max, tail) ->
    if !value
      return ''
    max = parseInt(max, 10)
    if !max
      return value
    if value.length <= max
      return value
    value = value.substr(0, max)
    if wordwise
      lastspace = value.lastIndexOf(' ')
      if lastspace != -1
        if value.charAt(lastspace - 1) == '.' or value.charAt(lastspace - 1) == ','
          lastspace = lastspace - 1
        value = value.substr(0, lastspace)
    value + (tail or ' …')
