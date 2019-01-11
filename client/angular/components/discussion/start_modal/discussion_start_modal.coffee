Records = require 'shared/services/records'

{ applyDiscussionStartSequence } = require 'shared/helpers/apply'

angular.module('loomioApp').factory 'DiscussionStartModal', ->
  template: require('./discussion_start_modal.haml')
  controller: ['$scope', 'discussion', ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    applyDiscussionStartSequence $scope,
      afterSaveComplete: (event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)
  ]
