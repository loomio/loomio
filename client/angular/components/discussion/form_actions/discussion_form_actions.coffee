Records = require 'shared/services/records.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ submitForm }    = require 'angular/helpers/form.coffee'
{ submitOnEnter } = require 'angular/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'discussionFormActions', ($location) ->
  scope: {discussion: '='}
  replace: true
  templateUrl: 'generated/components/discussion/form_actions/discussion_form_actions.html'
  controller: ($scope) ->
    actionName = if $scope.discussion.isNew() then 'created' else 'updated'

    $scope.submit = submitForm $scope, $scope.discussion,
      flashSuccess: "discussion_form.messages.#{actionName}"
      successCallback: (response) =>
        $scope.$emit '$close'
        _.invoke Records.documents.find($scope.discussion.removedDocumentIds), 'remove'
        discussion = Records.discussions.find(response.discussions[0].id)
        $location.path LmoUrlService.discussion(discussion) if actionName == 'created'

    submitOnEnter $scope
