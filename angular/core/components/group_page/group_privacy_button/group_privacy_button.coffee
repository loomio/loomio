angular.module('loomioApp').directive 'groupPrivacyButton', ->
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_privacy_button/group_privacy_button.html'
  replace: true
  scope: {group: '='}
  controller: ($scope, PrivacyString) ->

    $scope.iconClass = ->
      switch $scope.group.groupPrivacy
        when 'open'   then 'fa-globe'
        when 'closed' then 'fa-lock'
        when 'secret' then 'fa-lock'

    $scope.privacyDescription = ->
      PrivacyString.group($scope.group)
