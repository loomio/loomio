{ groupPrivacy } = require 'angular/helpers/helptext.coffee'

angular.module('loomioApp').directive 'groupPrivacyButton', ($translate) ->
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_privacy_button/group_privacy_button.html'
  replace: true
  scope: {group: '='}
  controller: ($scope) ->

    $scope.iconClass = ->
      switch $scope.group.groupPrivacy
        when 'open'   then 'mdi-earth'
        when 'closed' then 'mdi-lock-outline'
        when 'secret' then 'mdi-lock-outline'

    $scope.privacyDescription = ->
      $translate.instant groupPrivacy($scope.group)
