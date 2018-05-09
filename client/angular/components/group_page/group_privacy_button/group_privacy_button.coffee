I18n = require 'shared/services/i18n'

{ groupPrivacy } = require 'shared/helpers/helptext'

angular.module('loomioApp').directive 'groupPrivacyButton', ->
  restrict: 'E'
  templateUrl: 'generated/components/group_page/group_privacy_button/group_privacy_button.html'
  replace: true
  scope: {group: '='}
  controller: ['$scope', ($scope) ->

    $scope.iconClass = ->
      switch $scope.group.groupPrivacy
        when 'open'   then 'mdi-earth'
        when 'closed' then 'mdi-lock-outline'
        when 'secret' then 'mdi-lock-outline'

    $scope.privacyDescription = ->
      I18n.t groupPrivacy($scope.group)
  ]
