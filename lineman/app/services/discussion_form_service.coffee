angular.module('loomioApp').factory 'DiscussionFormService', ($modal, Records) ->
  new class DiscussionFormService
    openNewDiscussionModal: ->
      modalInstance = $modal.open
        templateUrl: 'modules/discussion_page/discussion_form/discussion_form.html'
        controller: 'DiscussionFormController'
        resolve:
          discussion: -> Records.discussions.initialize()
