EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
Records        = require 'shared/services/records'
Session        = require 'shared/services/session'
FlashService   = require 'shared/services/flash_service'

{ signIn }            = require 'shared/helpers/user'
{ fieldFromTemplate } = require 'shared/helpers/poll'
{ scrollTo }          = require 'shared/helpers/layout'

# a helper to aid submitting forms throughout the app
module.exports =
  submitForm: (scope, model, options = {}) ->
    submit(scope, model, options)

  submitDiscussion: (scope, model, options = {}) ->
    submit(scope, model, _.merge(
      submitFn: if model.isForking() then model.fork else model.save
      flashSuccess: "discussion_form.messages.#{actionName(model)}"
      failureCallback: ->
        scrollTo '.lmo-validation-error__message', container: '.discussion-modal'
      successCallback: (data) ->
        _.invokeMap Records.documents.find(model.removedDocumentIds), 'remove'
        if model.isForking()
          model.forkTarget().discussion().forkedEventIds = []
          _.invokeMap Records.events.find(model.forkedEventIds), 'remove'
        nextOrSkip(data, scope, model)
    , options))

  submitOutcome: (scope, model, options = {}) ->
    submit(scope, model, _.merge(
      flashSuccess: "poll_common_outcome_form.outcome_#{actionName(model)}"
      failureCallback: ->
        scrollTo '.lmo-validation-error__message', container: '.poll-common-modal'
      successCallback: (data) ->
        nextOrSkip(data, scope, model)
    , options))

  submitStance: (scope, model, options = {}) ->
    submit(scope, model, _.merge(
      flashSuccess: "poll_#{model.poll().pollType}_vote_form.stance_#{actionName(model)}"
      prepareFn: ->
        EventBus.emit scope, 'processing'
      successCallback: (data) ->
        model.poll().clearStaleStances()
        scrollTo '.poll-common-card__results-shown'
        EventBus.emit scope, 'stanceSaved'
        signIn(data, data.stances[0].participant_id, -> EventBus.emit scope, 'loggedIn') unless Session.user().emailVerified
      cleanupFn: ->
        EventBus.emit scope, 'doneProcessing'
    , options))

  submitPoll: (scope, model, options = {}) ->
    submit(scope, model, _.merge(
      flashSuccess: "poll_#{model.pollType}_form.#{model.pollType}_#{actionName(model)}"
      prepareFn: =>
        EventBus.$emit scope, 'processing'
        model.customFields.deanonymize_after_close = model.deanonymizeAfterClose if model.anonymous
        switch model.pollType
          # for polls with default poll options (proposal, check)
          when 'proposal', 'count'
            model.pollOptionNames = _.map fieldFromTemplate(model.pollType, 'poll_options_attributes'), 'name'
          # for polls with user-specified poll options (poll, dot_vote, ranked_choice, meeting
          when 'meeting'
            model.customFields.can_respond_maybe = model.canRespondMaybe
            model.addOption()
          else
            model.addOption()
      failureCallback: ->
        scrollTo '.lmo-validation-error__message', container: '.poll-common-modal'
      successCallback: (data) ->
        _.invokeMap Records.documents.find(model.removedDocumentIds), 'remove'
        model.removeOrphanOptions()
        nextOrSkip(data, scope, model)
      cleanupFn: ->
        EventBus.emit scope, 'doneProcessing'
    , options))

  submitMembership: (scope, model, options = {}) ->
    submit(scope, model, _.merge(
      flashSuccess: "membership_form.#{actionName(model)}"
      successCallback: -> EventBus.emit scope, '$close'
    , options))

  upload: (scope, model, options = {}) ->
    upload(scope, model, options)

  uploadForm: (scope, element, model, options = {}) ->
    scope.upload     = upload(scope, model, options)
    scope.selectFile = -> element[0].querySelector('input[type=file]').click()
    scope.drop       = (event) -> scope.upload(event.dataTransfer.files)
    if !options.disablePaste
      EventBus.$on 'filesPasted', (_, files) -> scope.upload(files)

upload = (scope, model, options) ->
  submitFn = options.submitFn or Records.documents.upload
  options.loadingMessage = options.loadingMessage or 'common.action.uploading'
  (files) ->
    scope.files = files
    prepare(scope, model, options)
    for file in files
      submitFn(file, progress(scope)).then(
        success(scope, model, options),
        failure(scope, model, options)
      ).finally(
        cleanup(scope, model, options)
      )

submit = (scope, model, options = {}) ->
  # fetch draft from server and listen for changes to it
  # if model.hasDrafts and model.isNew() and AbilityService.isLoggedIn()
  #   model.fetchAndRestoreDraft()
  #   EventBus.watch scope, model.draftFields, model.planDraftFetch, true

  submitFn  = options.submitFn  or model.save
  confirmFn = options.confirmFn or (-> false)
  (prepareArgs) ->
    return if scope.isDisabled
    prepare(scope, model, options, prepareArgs)
    if confirm(confirmFn(model))
      submitFn(model).then(
        success(scope, model, options),
        failure(scope, model, options),
      ).finally(
        cleanup(scope, model, options)
      )
    else
      cleanup(scope, model, options)

prepare = (scope, model, options, prepareArgs) ->
  FlashService.loading(options.loadingMessage)
  options.prepareFn(prepareArgs) if typeof options.prepareFn is 'function'
  EventBus.emit scope, 'processing'
  model.cancelDraftFetch()       if typeof model.cancelDraftFetch is 'function'
  model.clearDrafts()            if typeof model.clearDrafts      is 'function'
  model.setErrors()
  scope.isDisabled = true

confirm = (confirmMessage) ->
  if confirmMessage and typeof window.confirm == 'function'
    window.confirm(confirmMessage)
  else
    true

progress = (scope) ->
  (progress) ->
    return unless progress.total > 0
    scope.percentComplete = Math.floor(100 * progress.loaded / progress.total)
    scope.$apply()

success = (scope, model, options) ->
  (data) ->
    FlashService.dismiss()
    if options.flashSuccess?
      flashKey     = if typeof options.flashSuccess is 'function' then options.flashSuccess() else options.flashSuccess
      FlashService.success flashKey, calculateFlashOptions(options.flashOptions)
    scope.$close()                if !options.skipClose? and typeof scope.$close is 'function'
    options.successCallback(data) if typeof options.successCallback is 'function'

failure = (scope, model, options) ->
  (response) ->
    FlashService.dismiss()
    options.failureCallback(response) if typeof options.failureCallback is 'function'
    setErrors(scope, model, response) if _.includes([401, 422], response.status)
    EventBus.emit scope, errorTypes[response.status] or 'unknownError',
      model: model
      response: response

cleanup = (scope, model, options = {}) ->
  ->
    options.cleanupFn(scope, model) if typeof options.cleanupFn is 'function'
    EventBus.emit scope, 'doneProcessing' unless options.skipDoneProcessing
    scope.isDisabled = false
    scope.files = null        if scope.files
    scope.percentComplete = 0 if scope.percentComplete

calculateFlashOptions = (options) ->
  _.each _.keys(options), (key) ->
    options[key] = options[key]() if typeof options[key] is 'function'
  options

nextOrSkip = (data, scope, model) ->
  eventData = _.find(data.events, (event) -> event.kind == eventKind(model)) || {}
  if event = Records.events.find(eventData.id)
    EventBus.emit scope, 'nextStep', event
  else
    EventBus.emit scope, 'skipStep'

actionName = (model) ->
  return 'forked' if model.isA('discussion') and model.isForking()
  if model.isNew() then 'created' else 'updated'

setErrors = (scope, model, response) ->
  response.json().then (r) ->
    model.setErrors(r.errors)
    scope.$apply()

eventKind = (model) ->
  if model.isA('discussion') and model.isNew()
    return if model.isForking() then 'discussion_forked' else 'new_discussion'

  if model.isNew()
    "#{model.constructor.singular}_created"
  else
    "#{model.constructor.singular}_edited"

errorTypes =
  400: 'badRequest'
  401: 'unauthorizedRequest'
  403: 'forbiddenRequest'
  404: 'resourceNotFound'
  422: 'unprocessableEntity'
  500: 'internalServerError'
