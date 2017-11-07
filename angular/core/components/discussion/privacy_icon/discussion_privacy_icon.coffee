angular.module('loomioApp').directive 'discussionPrivacyIcon', (PrivacyString) ->
  scope: {discussion: '=', private: '=?'}
  templateUrl: 'generated/components/discussion/privacy_icon/discussion_privacy_icon.html'
  controller: ($scope) ->
    $scope.private = $scope.discussion.private if typeof $scope.private == 'undefined'

    $scope.translateKey = ->
      if $scope.private then 'private' else 'public'

    $scope.privacyDescription = ->
      PrivacyString.discussion($scope.discussion, $scope.private)
