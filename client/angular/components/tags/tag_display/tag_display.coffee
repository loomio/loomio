Records = require 'shared/services/records.coffee'

angular.module('loomioApp').directive 'tagDisplay', ->
  scope: {discussion: '='}
  restrict: 'E'
  replace: true
  templateUrl: 'generated/components/tags/tag_display/tag_display.html'
  controller: ['$scope', ($scope) ->
    $scope.anyTags = ->
      _.some $scope.discussionTags()

    $scope.discussionTags = ->
      Records.discussionTags.find discussionId: $scope.discussion.id

    return
  ]
