angular.module('loomioApp').directive 'groupAvatar', ->
  scope: {group: '=', size: '@?'}
  restrict: 'E'
  template: require('./group_avatar.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    sizes = ['small', 'medium', 'large']
    unless _.includes(sizes, $scope.size)
      $scope.size = 'small'
  ]
