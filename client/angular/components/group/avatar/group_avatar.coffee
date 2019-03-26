angular.module('loomioApp').directive 'groupAvatar', ->
  scope: {group: '=', size: '@?'}
  restrict: 'E'
  templateUrl: 'generated/components/group/avatar/group_avatar.html'
  replace: true
  controller: ['$scope', ($scope) ->
    sizes = ['small', 'medium', 'large']
    unless _.includes(sizes, $scope.size)
      $scope.size = 'small'
  ]
