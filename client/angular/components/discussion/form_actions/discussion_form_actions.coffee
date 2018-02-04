Records       = require 'shared/services/records.coffee'
EventBus      = require 'shared/services/event_bus.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ submitDiscussion } = require 'shared/helpers/form.coffee'
{ submitOnEnter }    = require 'shared/helpers/keyboard.coffee'

angular.module('loomioApp').directive 'discussionFormActions', ->
  scope: {discussion: '='}
  replace: true
  templateUrl: 'generated/components/discussion/form_actions/discussion_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = submitDiscussion $scope, $scope.discussion
    submitOnEnter $scope
  ]
