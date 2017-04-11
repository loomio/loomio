angular.module('loomioApp').directive 'pollMeetingForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/meeting/form/poll_meeting_form.html'
  controller: ($scope, PollService, AttachmentService, KeyEventService, TranslationService, TimeService) ->
    TranslationService.eagerTranslate $scope,
      titlePlaceholder:     'poll_meeting_form.title_placeholder'
      detailsPlaceholder:   'poll_meeting_form.details_placeholder'

    $scope.removeOption = (name) ->
      _.pull $scope.poll.pollOptionNames, name

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: -> $scope.$broadcast 'addOption'

    $scope.$on 'timeZoneSelected', (e, zone) ->
      $scope.poll.customFields.time_zone = zone

    KeyEventService.submitOnEnter($scope)
