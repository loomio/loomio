I18n = require 'shared/services/i18n'

{ discussionPrivacy } = require 'shared/helpers/helptext'

angular.module('loomioApp').directive 'discussionPrivacyIcon', ->
  scope: {discussion: '=', private: '=?'}
  templateUrl: 'generated/components/discussion/privacy_icon/discussion_privacy_icon.html'
  controller: ['$scope', ($scope) ->
    $scope.private = $scope.discussion.private if typeof $scope.private == 'undefined'

    $scope.translateKey = ->
      if $scope.private then 'private' else 'public'

    $scope.privacyDescription = ->
      I18n.t discussionPrivacy($scope.discussion, $scope.private),
        group:  $scope.discussion.group().name
        parent: $scope.discussion.group().parentName()
  ]
