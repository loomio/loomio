Records        = require 'shared/services/records.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'tagList',->
  scope: {group: '=?', discussion: '=?', admin: '='}
  restrict: 'E'
  templateUrl: 'generated/components/tags/tag_list/tag_list.html'
  controller: ['$scope', ($scope) ->
    $scope.parent = ($scope.group or $scope.discussion.group()).parentOrSelf()
    Records.tags.fetchByGroup($scope.parent)

    $scope.groupTags = ->
      Records.tags.find(groupId: $scope.parent.id)

    $scope.tagSelected = (tagId) ->
      _.some Records.discussionTags.find(discussionId: $scope.discussion.id, tagId: tagId)

    $scope.canAdministerGroup = ->
      AbilityService.canAdministerGroup $scope.parent

    $scope.editTag = (tag) ->
      EventBus.emit $scope, 'editTag', tag
  ]
