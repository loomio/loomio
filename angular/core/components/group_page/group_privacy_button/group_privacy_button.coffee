angular.module('loomioApp').directive 'groupPrivacyButton', ->
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_privacy_button/group_privacy_button.html'
  replace: true
  scope: {group: '='}
  controller: ($scope, PrivacyString) ->

    $scope.iconClass = ->
      switch $scope.group.groupPrivacy
        when 'open'   then 'public'
        when 'closed' then 'locked'
        when 'secret' then 'locked'

    $scope.privacyDescription = ->
      PrivacyString.group($scope.group)
