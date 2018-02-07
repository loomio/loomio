Session      = require 'shared/services/session.coffee'
Records      = require 'shared/services/records.coffee'
FlashService = require 'shared/services/flash_service.coffee'
ModalService = require 'shared/services/modal_service.coffee'

module.exports = new class ThreadService
  mute: (thread) ->
    if !Session.user().hasExperienced("mutingThread")
      Records.users.saveExperience("mutingThread")
      Records.users.updateProfile(Session.user()).then ->
        ModalService.open 'MuteExplanationModal', thread: -> thread
    else
      previousVolume = thread.volume()
      thread.saveVolume('mute').then =>
        FlashService.success "discussion.volume.mute_message",
          name: thread.title
        , 'undo', => @unmute(thread, previousVolume)

  unmute: (thread, previousVolume = 'normal') ->
    thread.saveVolume(previousVolume).then =>
      FlashService.success "discussion.volume.unmute_message",
        name: thread.title
      , 'undo', => @mute(thread)

  close: (thread) ->
    if !Session.user().hasExperienced("closingThread")
      Records.users.saveExperience("closingThread")
      Records.users.updateProfile(Session.user()).then ->
        ModalService.open 'CloseExplanationModal', thread: -> thread
    else
      thread.close().then =>
        FlashService.success "discussion.closed.closed",
          name: thread.title
        , 'undo', => @reopen(thread)

  reopen: (thread) ->
    thread.reopen().then =>
      FlashService.success "discussion.closed.reopened", {}, 'undo', => @close(thread)

  dismiss: (thread) ->
    if !Session.user().hasExperienced("dismissThread")
      Records.users.saveExperience("dismissThread")
      ModalService.open 'DismissExplanationModal', thread: -> thread
    else
      thread.dismiss().then =>
        FlashService.success "dashboard_page.thread_dismissed", {}, 'undo', => @recall(thread)

  recall: (thread) ->
    thread.recall().then =>
      FlashService.success "dashboard_page.thread_recalled", {}, 'undo', => @dismiss(thread)

  pin: (thread) ->
    if !Session.user().hasExperienced("pinningThread")
      Records.users.saveExperience("pinningThread").then ->
        ModalService.open 'PinThreadModal', thread: -> thread
    else
      thread.savePin().then =>
        FlashService.success "discussion.pin.pinned", 'undo', => @unpin(thread)

  unpin: (thread) ->
    thread.savePin().then =>
      FlashService.success "discussion.pin.unpinned", 'undo', => @pin(thread)
