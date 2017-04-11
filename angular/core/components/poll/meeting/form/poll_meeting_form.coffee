angular.module('loomioApp').directive 'pollMeetingForm', ->
  scope: {poll: '=', back: '=?'}
  templateUrl: 'generated/components/poll/meeting/form/poll_meeting_form.html'
  controller: ($scope, PollService, AttachmentService, KeyEventService, TranslationService) ->
    TranslationService.eagerTranslate $scope,
      titlePlaceholder:     'poll_meeting_form.title_placeholder'
      detailsPlaceholder:   'poll_meeting_form.details_placeholder'

    $scope.removeOption = (name) ->
      _.pull $scope.poll.pollOptionNames, name

    $scope.submit = PollService.submitPoll $scope, $scope.poll,
      prepareFn: -> $scope.$broadcast 'addOption'

    $scope.formatDate = (name) ->
      moment(name).format($scope.formatFor(name))

    $scope.formatFor = (name) ->
      m = moment(name)
      switch m._f
        when "YYYY-MM-DDTHH:mm:ss.SSSSZ"
          if m.year() == moment().year()
            "D MMMM - h:mma"
          else
            "D MMMM YYYY - h:mma"
        when "YYYY-MM-DD"
          if m.year() == moment().year()
            "D MMMM"
          else
            "D MMMM YYYY"

    KeyEventService.submitOnEnter($scope)
