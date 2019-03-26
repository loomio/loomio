Records = require 'shared/services/records'

{ applySequence } = require 'shared/helpers/apply'
{ obeyMembersCanAnnounce } = require 'shared/helpers/apply'

angular.module('loomioApp').factory 'DiscussionEditModal', ->
  templateUrl: 'generated/components/discussion/edit_modal/discussion_edit_modal.html'
  controller: ['$scope', 'discussion', ($scope, discussion) ->
    $scope.discussion = discussion.clone()

    applySequence $scope,
      steps: obeyMembersCanAnnounce(['save', 'announce'], $scope.discussion.group()),
      saveComplete: (_, event) ->
        $scope.announcement = Records.announcements.buildFromModel(event)
  ]
