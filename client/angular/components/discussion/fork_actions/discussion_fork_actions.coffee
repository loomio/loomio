Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'

angular.module('loomioApp').directive 'discussionForkActions', ->
  scope: {discussion: '='}
  template: require('./discussion_fork_actions.haml')
  controller: ['$scope', ($scope) ->
    $scope.submit = ->
      ModalService.open 'DiscussionStartModal', discussion: ->
        Records.discussions.build
          groupId:        $scope.discussion.groupId
          private:        $scope.discussion.private
          forkedEventIds: $scope.discussion.forkedEventIds
  ]
