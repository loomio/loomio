AppConfig = require 'shared/services/app_config'
Session   = require 'shared/services/session'

angular.module('loomioApp').directive 'installSlackInvitePreview', ['$timeout', ($timeout) ->
  templateUrl: 'generated/components/install_slack/invite_preview/install_slack_invite_preview.html'
  controller: ['$scope', ($scope) ->
    $timeout ->
      $scope.group     = AppConfig.currentGroup
      $scope.userName  = Session.user().name
      $scope.timestamp = -> moment().format('h:ma')
  ]
]
