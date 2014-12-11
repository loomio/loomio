angular.module('loomioApp').factory 'DiscussionFormService', ($modal, Records) ->
  new class DiscussionFormService
    openEditDiscussionModal: (discussion) ->
      $modal.open
        templateUrl: 'generated/modules/discussion_page/discussion_form/discussion_form.html',
        controller: 'DiscussionFormController',
        resolve:
          discussion: -> angular.copy(discussion)

    openNewDiscussionModal: ->
      $modal.open
        templateUrl: 'modules/discussion_page/discussion_form/discussion_form.html'
        controller: 'DiscussionFormController'
        resolve:
          discussion: -> Records.discussions.initialize()
