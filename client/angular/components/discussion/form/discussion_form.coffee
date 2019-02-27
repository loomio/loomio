Session        = require 'shared/services/session'
AbilityService = require 'shared/services/ability_service'
I18n           = require 'shared/services/i18n'
AppConfig = require 'shared/services/app_config'

{ discussionPrivacy } = require 'shared/helpers/helptext'

angular.module('loomioApp').directive 'discussionForm', ->
  scope: {discussion: '='}
  templateUrl: 'generated/components/discussion/form/discussion_form.html'
  controller: ['$scope', ($scope) ->
    $scope.canStartThread = true
    $scope.$watch 'discussion.groupId', (o, v)->
      return unless $scope.discussion.groupId
      $scope.maxThreads = $scope.discussion.group().parentOrSelf().subscriptionMaxThreads
      $scope.threadCount = $scope.discussion.group().parentOrSelf().orgDiscussionsCount
      $scope.maxThreadsReached = $scope.maxThreads && $scope.threadCount >= $scope.maxThreads
      $scope.subscriptionActive = $scope.discussion.group().parentOrSelf().subscriptionActive
      $scope.upgradeUrl = AppConfig.baseUrl + 'upgrade'
      $scope.canStartThread = $scope.subscriptionActive && !$scope.maxThreadsReached

    if $scope.discussion.isNew()
      $scope.showGroupSelect = true

    $scope.availableGroups = ->
      _.filter Session.user().formalGroups(), (group) ->
        AbilityService.canStartThread(group)

    $scope.privacyPrivateDescription = ->
      I18n.t discussionPrivacy($scope.discussion, true),
        group:  $scope.discussion.group().name,
        parent: $scope.discussion.group().parentName()

    $scope.updatePrivacy = ->
      $scope.discussion.private = $scope.discussion.privateDefaultValue()

    $scope.showPrivacyForm = ->
      return unless $scope.discussion.group()
      $scope.discussion.group().discussionPrivacyOptions == 'public_or_private'
  ]
