angular.module('loomioApp').directive 'pollCommonCollapsed', ->
  scope: {poll: '='}
  template: require('./poll_common_collapsed.haml')
  controller: ['$scope', ($scope) ->

    $scope.formattedPollType = (type) ->
      _.capitalize type.replace('_', '-')
  ]
