angular.module('loomioApp').directive 'pollCommonFormFields', ($translate, Records, Session, AbilityService, EmojiService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/form_fields/poll_common_form_fields.html'
  controller: ($scope) ->
    $scope.availableGroups = ->
      _.filter Session.user().formalGroups(), (group) ->
        AbilityService.canStartPoll(group)

    $scope.showGroupSelect = $scope.poll.isNew()

    # NB; this overrides the restoreDraft() function applied in draft_service
    $scope.restoreDraft = ->
      return unless $scope.poll.group()? and $scope.poll.isNew()
      $scope.poll.restoreDraft()

    $scope.titlePlaceholder = ->
      $translate.instant("poll_#{$scope.poll.pollType}_form.title_placeholder")

    $scope.detailsPlaceholder = ->
      $translate.instant("poll_#{$scope.poll.pollType}_form.details_placeholder")

    $scope.showGroupSelect = $scope.poll.isNew()

    if !$scope.poll.isNew()
      # notify the participants of the poll by default
      Records.notified.fetchByPoll($scope.poll.key).then (notified) ->
        $scope.poll.notified = notified
