angular.module('loomioApp').directive 'groupCollection', ->
  scope: {model: '='}
  templateUrl: 'generated/components/group/collection/group_collection.html'
  controller: ($scope) ->
    $scope.groupCover = (group) ->
      { 'background-image': "url(#{group.coverUrl('small')})" }

    $scope.groupDescription = (group) ->
      _.trunc group.description, 100 if group.description
