angular.module('loomioApp').directive 'groupAvatar', ->
  scope: {group: '=', size: '@?'}
  restrict: 'E'
  templateUrl: 'generated/components/group_avatar/group_avatar.html'
  replace: true
  controller: ['$scope', ($scope) ->
    sizes = ['small', 'medium', 'large']
    unless _.contains(sizes, $scope.size)
      $scope.size = 'small'
  ]
