angular.module('loomioApp').factory 'PollService', ($window, $location, AppConfig, Records, FormService, LmoUrlService, AbilityService, AttachmentService) ->
  new class PollService

    # NB: this is an intersection of data and code that's a little uncomfortable at the moment.
    # right now you can define polls in poll_templates.yml that won't come through in the interface unless
    # the right components are defined, or you could have components which don't have a matching poll type serverside.

    # Ideally, we write these proposal types as plugins, which say 'Hey, add these components,
    # and add this poll type to the yml data', at the same time.
    # This will also make it easier to switch poll types on and off per instance, and per group.

    activePollTemplates: ->
      # this could have group-specific logic later.
      AppConfig.pollTemplates

    fieldFromTemplate: (pollType, field) ->
      return unless template = @templateFor(pollType)
      template[field]

    templateFor: (pollType) ->
      @activePollTemplates()[pollType]

    lastStanceBy: (participant, poll) ->
      criteria =
        latest:    true
        pollId:    poll.id
        visitorId: AppConfig.currentVisitorId or null
        userId:    AppConfig.currentUserId or null
      _.first _.sortBy(Records.stances.find(criteria), 'createdAt')

    hasVoted: (participant, poll) ->
      @lastStanceBy(participant, poll)?

    iconFor: (poll) ->
      @fieldFromTemplate(poll.pollType, 'material_icon')

    usePollsFor: (model) ->
      model.group().features.use_polls && !$location.search().proposalView

    optionByName: (poll, name) ->
      _.find poll.pollOptions(), (option) -> option.name == name

    submitPoll: (scope, model, options = {}) ->
      actionName = if scope.poll.isNew() then 'created' else 'updated'
      FormService.submit(scope, model, _.merge(
        flashSuccess: "poll_#{model.pollType}_form.#{model.pollType}_#{actionName}"
        drafts: true
        successCallback: (data) ->
          scope.$emit 'pollSaved', data.polls[0].key
          AttachmentService.cleanupAfterUpdate(data.polls[0], 'poll')
      , options))

    submitStance: (scope, model, options = {}) ->
      actionName = if scope.stance.isNew() then 'created' else 'updated'
      pollType   = model.poll().pollType
      FormService.submit(scope, model, _.merge(
        flashSuccess: "poll_#{pollType}_vote_form.stance_#{actionName}"
        drafts: true
        successCallback: (data) ->
          model.poll().clearStaleStances()
          AppConfig.currentVisitorId = data.stances[0].visitor_id
          scope.$emit 'stanceSaved', data.stances[0].key
      , options))
