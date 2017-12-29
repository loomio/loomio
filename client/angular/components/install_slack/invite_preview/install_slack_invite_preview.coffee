Session = require 'shared/services/session.coffee'
moment  = require 'moment'

angular.module('loomioApp').directive 'installSlackInvitePreview', ['$timeout', ($timeout) ->
  templateUrl: 'generated/components/install_slack/invite_preview/install_slack_invite_preview.html'
  controller: ['$scope', ($scope) ->
    $timeout ->
      $scope.group     = Session.currentGroup
      $scope.userName  = Session.user().name
      $scope.timestamp = -> moment().format('h:ma')
  ]
]
