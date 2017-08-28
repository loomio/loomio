angular.module('loomioApp').directive 'pollCommonFormFields', ($translate, Session, AbilityService, EmojiService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/form_fields/poll_common_form_fields.html'
  controller: ($scope) ->
    $scope.availableGroups = ->
      _.filter Session.user().groups(), (group) ->
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
