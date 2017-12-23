{ discussionPrivacy } = require 'angular/helpers/helptext.coffee'

angular.module('loomioApp').directive 'discussionPrivacyIcon', ($translate) ->
  scope: {discussion: '=', private: '=?'}
  templateUrl: 'generated/components/discussion/privacy_icon/discussion_privacy_icon.html'
  controller: ($scope) ->
    $scope.private = $scope.discussion.private if typeof $scope.private == 'undefined'

    $scope.translateKey = ->
      if $scope.private then 'private' else 'public'

    $scope.privacyDescription = ->
      $translate.instant discussionPrivacy($scope.discussion, $scope.private),
        group:  $scope.discussion.group().name
        parent: $scope.discussion.group().parentName()
