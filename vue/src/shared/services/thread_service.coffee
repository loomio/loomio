import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import FlashService  from '@/shared/services/flash_service'
import ModalService  from '@/shared/services/modal_service'

export default new class ThreadService
  mute: (thread, override = false) ->
    if !Session.user().hasExperienced("mutingThread") and !override
      Records.users.saveExperience("mutingThread")
      Records.users.updateProfile(Session.user()).then ->
        ModalService.open 'ConfirmModal', confirm: ->
          submit: -> thread.saveVolume('mute', true)
          text:
            title: 'mute_explanation_modal.mute_thread'
            flash: 'discussion.volume.mute_message'
            fragment: 'mute_thread'
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
        ModalService.open 'ConfirmModal', confirm: ->
          submit: thread.close
          text:
            title:    'close_explanation_modal.close_thread'
            fragment: 'close_thread'
            flash:    'discussion.closed.closed'
    else
      thread.close().then =>
        FlashService.success "discussion.closed.closed", {}, 'undo', => @reopen(thread)

  reopen: (thread) ->
    thread.reopen().then =>
      FlashService.success "discussion.closed.reopened", {}, 'undo', => @close(thread)

  dismiss: (thread) ->
    if !Session.user().hasExperienced("dismissThread")
      Records.users.saveExperience("dismissThread")
      ModalService.open 'ConfirmModal', confirm: =>
        submit: => @dismiss(thread)
        text:
          title:    'dismiss_explanation_modal.dismiss_thread'
          helptext: 'dismiss_explanation_modal.body_html'
          submit:   'dismiss_explanation_modal.dismiss_thread'
          flash:    'dashboard_page.thread_dismissed'
    else
      thread.dismiss().then =>
        FlashService.success "dashboard_page.thread_dismissed", {}, 'undo', => @recall(thread)

  recall: (thread) ->
    thread.recall().then =>
      FlashService.success "dashboard_page.thread_recalled", {}, 'undo', => @dismiss(thread)

  pin: (thread) ->
    if !Session.user().hasExperienced("pinningThread")
      Records.users.saveExperience("pinningThread").then ->
        ModalService.open 'ConfirmModal', confirm: ->
          submit:  thread.savePin
          text:
            title:    'pin_thread_modal.title'
            flash:    'discussion.pin.pinned'
            fragment: 'pin_thread'
    else
      thread.savePin().then =>
        FlashService.success "discussion.pin.pinned", 'undo', => @unpin(thread)

  unpin: (thread) ->
    thread.savePin().then =>
      FlashService.success "discussion.pin.unpinned", 'undo', => @pin(thread)
