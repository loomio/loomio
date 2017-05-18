angular.module('loomioApp').directive 'groupDecisionsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_decisions_card/group_decisions_card.html'
  replace: true
  controller: ($scope, Session, Records, AbilityService) ->
    if AbilityService.canViewPreviousPolls($scope.group)
      Records.polls.fetchByGroup($scope.group.key, per: 3).then ->
        Records.stances.fetchMyStances($scope.group.key) if AbilityService.isLoggedIn()

    $scope.pollCollection =
      polls: => _.take $scope.group.polls(), 5
