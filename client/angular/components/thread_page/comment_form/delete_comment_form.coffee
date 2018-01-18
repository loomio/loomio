Records = require 'shared/services/records.coffee'

angular.module('loomioApp').factory 'DeleteCommentForm', ->
  templateUrl: 'generated/components/thread_page/comment_form/delete_comment_form.html'
  controller: ['$scope', 'comment', ($scope, comment) ->
    $scope.comment = comment

    $scope.submit = ->
      $scope.comment.destroy().then -> $scope.$close()
  ]
