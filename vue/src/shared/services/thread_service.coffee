import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash  from '@/shared/services/flash'
import ConfirmModalMixin from '@/mixins/confirm_modal'

export default new class ThreadService
  mute: (thread, override = false) ->
    if !Session.user().hasExperienced("mutingThread") and !override
      Records.users.saveExperience("mutingThread")
      Records.users.updateProfile(Session.user()).then ->
        ConfirmModalMixin.methods.openConfirmModal(
          submit: => thread.saveVolume('mute', true)
          text:
            title: 'mute_explanation_modal.mute_thread'
            flash: 'discussion.volume.mute_message'
            fragment: 'mute_thread'
        )
    else
      previousVolume = thread.volume()
      thread.saveVolume('mute').then =>
        Flash.success "discussion.volume.mute_message",
          name: thread.title
        , 'undo', => @unmute(thread, previousVolume)

  unmute: (thread, previousVolume = 'normal') ->
    thread.saveVolume(previousVolume).then =>
      Flash.success "discussion.volume.unmute_message",
        name: thread.title
      , 'undo', => @mute(thread)

  close: (thread) ->
    if !Session.user().hasExperienced("closingThread")
      Records.users.saveExperience("closingThread")
      Records.users.updateProfile(Session.user()).then ->
        ConfirmModalMixin.methods.openConfirmModal(
          submit: thread.close
          text:
            title:    'close_explanation_modal.close_thread'
            fragment: 'close_thread'
            flash:    'discussion.closed.closed'
        )
    else
      thread.close().then =>
        Flash.success "discussion.closed.closed", {}, 'undo', => @reopen(thread)

  reopen: (thread) ->
    thread.reopen().then =>
      Flash.success "discussion.closed.reopened", {}, 'undo', => @close(thread)

  dismiss: (thread) ->
    if !Session.user().hasExperienced("dismissThread")
      Records.users.saveExperience("dismissThread")
      ConfirmModalMixin.methods.openConfirmModal(
        submit: => @dismiss(thread)
        text:
          title:    'dismiss_explanation_modal.dismiss_thread'
          helptext: 'dismiss_explanation_modal.body_html'
          submit:   'dismiss_explanation_modal.dismiss_thread'
          flash:    'dashboard_page.thread_dismissed'
      )
    else
      thread.dismiss().then =>
        Flash.success "dashboard_page.thread_dismissed", {}, 'undo', => @recall(thread)

  recall: (thread) ->
    thread.recall().then =>
      Flash.success "dashboard_page.thread_recalled", {}, 'undo', => @dismiss(thread)

  pin: (thread) ->
    if !Session.user().hasExperienced("pinningThread")
      Records.users.saveExperience("pinningThread").then ->
        ConfirmModalMixin.methods.openConfirmModal(
          submit:  thread.savePin
          text:
            title:    'pin_thread_modal.title'
            flash:    'discussion.pin.pinned'
            fragment: 'pin_thread'
        )
    else
      thread.savePin().then =>
        Flash.success "discussion.pin.pinned", 'undo', => @unpin(thread)

  unpin: (thread) ->
    thread.savePin().then =>
      Flash.success "discussion.pin.unpinned", 'undo', => @pin(thread)
