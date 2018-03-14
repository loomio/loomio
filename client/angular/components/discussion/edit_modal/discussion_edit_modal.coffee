Records = require 'shared/services/records.coffee'

{ applySequence } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').factory 'DiscussionEditModal', ->
  templateUrl: 'generated/components/discussion/edit_modal/discussion_edit_modal.html'
  controller: ['$scope', 'discussion', ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    applySequence $scope,
      steps: ['save', 'announce']
      saveComplete: (_, event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)
  ]
