angular.module('loomioApp').directive 'pollMeetingForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/meeting/form/poll_meeting_form.html'
  controller: ($scope, AppConfig, PollService, AttachmentService, KeyEventService, TranslationService, TimeService) ->
    TranslationService.eagerTranslate $scope,
      titlePlaceholder:     'poll_meeting_form.title_placeholder'
      detailsPlaceholder:   'poll_meeting_form.details_placeholder'
      addOptionPlaceholder: 'poll_meeting_form.add_option_placeholder'

    $scope.addOption = ->
      return unless $scope.newOptionName
      $scope.poll.pollOptionNames.push $scope.newOptionName

    $scope.removeOption = (name) ->
      _.pull $scope.poll.pollOptionNames, name

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: ->
        $scope.addOption()
        $scope.poll.pollOptionNames = _.map $scope.poll.pollOptionNames, (date) ->
          TimeService.isoDate(moment(date), $scope.poll.customFields.time_zone)

    $scope.$on 'timeZoneSelected', (e, zone) ->
      $scope.poll.customFields.time_zone = zone

    KeyEventService.submitOnEnter($scope)
    KeyEventService.registerKeyEvent $scope, 'pressedEnter', $scope.addOption, (active) ->
      active.classList.contains('poll-meeting-form__add-option-input')
