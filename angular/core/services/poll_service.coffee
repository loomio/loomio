angular.module('loomioApp').factory 'PollService', ($window, $location, AppConfig, Records, Session, SequenceService, FormService, LmoUrlService, ScrollService, AbilityService, AttachmentService) ->
  new class PollService

    # NB: this is an intersection of data and code that's a little uncomfortable at the moment.
    # right now you can define polls in poll_templates.yml that won't come through in the interface unless
    # the right components are defined, or you could have components which don't have a matching poll type serverside.

    # Ideally, we write these proposal types as plugins, which say 'Hey, add these components,
    # and add this poll type to the yml data', at the same time.
    # This will also make it easier to switch poll types on and off per instance, and per group.

    activePollTemplates: ->
      # this could have group-specific logic later.
      # (LATER...) gasp now it does!
      _.pickBy AppConfig.pollTemplates, (template) ->
        !template.experimental or
        (Session.currentGroup or {}).enableExperiments

    fieldFromTemplate: (pollType, field) ->
      return unless template = @templateFor(pollType)
      template[field]

    templateFor: (pollType) ->
      AppConfig.pollTemplates[pollType]

    lastStanceBy: (participant, poll) ->
      criteria =
        latest: true
        pollId: poll.id
        participantId: AppConfig.currentUserId
      _.first _.sortBy(Records.stances.find(criteria), 'createdAt')

    hasVoted: (user, poll) ->
      @lastStanceBy(user, poll)?

    iconFor: (poll) ->
      @fieldFromTemplate(poll.pollType, 'material_icon')

    optionByName: (poll, name) ->
      _.find poll.pollOptions(), (option) -> option.name == name

    applyPollStartSequence: (scope, options = {}) ->
      emitter = options.emitter or scope
      SequenceService.applySequence emitter, ['choose', 'save', 'share'],
        initialStep: if scope.poll.pollType then 'save' else 'choose'
        emitter: emitter
        chooseComplete: (_, pollType) ->
          scope.poll.pollType = pollType
        saveComplete: (_, poll) ->
          if poll.group() then emitter.$emit '$close' else scope.poll = poll
        shareComplete: ->
          emitter.$emit '$close'

    submitOutcome: (scope, model, options = {}) ->
      actionName = if scope.outcome.isNew() then 'created' else 'updated'
      FormService.submit(scope, model, _.merge(
        flashSuccess: "poll_common_outcome_form.outcome_#{actionName}"
        drafts: true
        failureCallback: ->
          ScrollService.scrollTo '.lmo-validation-error__message', container: '.poll-common-modal'
        successCallback: (data) ->
          scope.$emit 'outcomeSaved', data.outcomes[0].id
      , options))

    submitPoll: (scope, model, options = {}) ->
      actionName = if scope.poll.isNew() then 'created' else 'updated'
      FormService.submit(scope, model, _.merge(
        flashSuccess: "poll_#{model.pollType}_form.#{model.pollType}_#{actionName}"
        drafts: true
        prepareFn: =>
          scope.$emit 'processing'
          switch model.pollType
            # for polls with default poll options (proposal, check)
            when 'proposal', 'check'
              model.pollOptionNames = _.pluck @fieldFromTemplate(model.pollType, 'poll_options_attributes'), 'name'
            # for polls with user-specified poll options (poll, dot_vote, ranked_choice, meeting
            else
              scope.$broadcast 'addPollOption'
        failureCallback: ->
          ScrollService.scrollTo '.lmo-validation-error__message', container: '.poll-common-modal'
        successCallback: (data) ->
          poll = Records.polls.find(data.polls[0].key)
          scope.$emit 'nextStep', poll
          if actionName == 'created'
            $location.path(LmoUrlService.poll(poll))
          else
            AttachmentService.cleanupAfterUpdate(poll, 'poll')
        cleanupFn: ->
          scope.$emit 'doneProcessing'
      , options))

    submitStance: (scope, model, options = {}) ->
      actionName = if scope.stance.isNew() then 'created' else 'updated'
      pollType   = model.poll().pollType
      FormService.submit(scope, model, _.merge(
        flashSuccess: "poll_#{pollType}_vote_form.stance_#{actionName}"
        drafts: true
        prepareFn: ->
          scope.$emit 'processing'
        successCallback: (data) ->
          model.poll().clearStaleStances()
          ScrollService.scrollTo '.poll-common-card__results-shown'
          scope.$emit 'stanceSaved', data.stances[0].key
          Session.login(current_user_id: data.stances[0].participant_id) unless Session.user().emailVerified
        cleanupFn: ->
          scope.$emit 'doneProcessing'
      , options))
