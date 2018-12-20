Records = require 'shared/services/records'

{ submitForm }    = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').factory 'EditCommentForm', ->
  templateUrl: 'generated/components/thread_page/comment_form/edit_comment_form.html'
  controller: ['$scope', 'comment', ($scope, comment) ->
    $scope.comment = comment.clone()

    $scope.submit = submitForm $scope, $scope.comment,
      flashSuccess: 'comment_form.messages.updated'
      successCallback: ->
        _.invokeMap Records.documents.find($scope.comment.removedDocumentIds), 'remove'
    submitOnEnter $scope
  ]
