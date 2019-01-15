Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'tagDisplay', ->
  scope: {discussion: '='}
  restrict: 'E'
  replace: true
  template: require('./tag_display.haml')
  controller: ['$scope', ($scope) ->
    $scope.anyTags = ->
      _.some $scope.discussionTags()

    $scope.discussionTags = ->
      Records.discussionTags.find discussionId: $scope.discussion.id

    return
  ]
