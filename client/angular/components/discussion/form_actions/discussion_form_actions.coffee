Records       = require 'shared/services/records'
EventBus      = require 'shared/services/event_bus'
LmoUrlService = require 'shared/services/lmo_url_service'

{ submitDiscussion } = require 'shared/helpers/form'
{ submitOnEnter }    = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'discussionFormActions', ->
  scope: {discussion: '='}
  replace: true
  templateUrl: 'generated/components/discussion/form_actions/discussion_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = submitDiscussion $scope, $scope.discussion
    submitOnEnter $scope
  ]
