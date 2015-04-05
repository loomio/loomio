angular.module('loomioApp').factory 'DiscussionFormService', ($modal, Records) ->
  new class DiscussionFormService
    openEditDiscussionModal: (discussion) ->
      $modal.open
        templateUrl: 'generated/components/thread_page/discussion_form/discussion_form.html',
        controller: 'DiscussionFormController',
        resolve:
          discussion: -> Records.discussions.find(discussion.id)

    openNewDiscussionModal: (group = {}) ->
      $modal.open
        templateUrl: 'generated/components/thread_page/discussion_form/discussion_form.html'
        controller: 'DiscussionFormController'
        resolve:
          discussion: -> Records.discussions.initialize group_id: group.id
