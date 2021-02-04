import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import { hardReload } from '@/shared/helpers/window'

export default new class ThreadService
  actions: (discussion, vm) ->
    subscribe:
      name: 'common.action.subscribe'
      canPerform: ->
        discussion.volume() == 'normal' && AbilityService.canChangeVolume(discussion)
      perform: ->
        openModal
          component: 'ChangeVolumeForm'
          props:
            model: discussion

    unsubscribe:
      name: 'common.action.unsubscribe'
      canPerform: ->
        discussion.volume() == 'loud' && AbilityService.canChangeVolume(discussion)
      perform: ->
        openModal
          component: 'ChangeVolumeForm'
          props:
            model: discussion

    export_thread:
      name: 'common.action.print'
      canPerform: ->
        AbilityService.canExportThread(discussion)
      perform: ->
        hardReload LmoUrlService.discussion(discussion, {export: 1}, {absolute: true, print: true})

    unignore:
      name: 'common.action.unignore'
      canPerform: ->
        discussion.volume() == 'quiet' && AbilityService.canChangeVolume(discussion)
      perform: ->
        openModal
          component: 'ChangeVolumeForm'
          props:
            model: discussion

    notification_history:
      name: 'action_dock.show_notifications'
      icon: 'mdi-alarm-check'
      perform: ->
        openModal
          component: 'AnnouncementHistory'
          props:
            model: discussion
      canPerform: -> true

    pin_thread:
      icon: 'mdi-pin'
      name: 'action_dock.pin_thread'
      canPerform: -> AbilityService.canPinThread(discussion)
      perform: => @pin(discussion)

    unpin_thread:
      icon: 'mdi-pin-off'
      name: 'action_dock.unpin_thread'
      canPerform: -> AbilityService.canUnpinThread(discussion)
      perform: => @unpin(discussion)

    dismiss_thread:
      name: 'dashboard_page.mark_as_read'
      icon: 'mdi-check'
      canPerform: -> discussion.isUnread()
      perform: => @dismiss(discussion)

    announce_thread:
      name: 'common.action.invite'
      icon: 'mdi-send'
      canPerform: ->
        discussion.group().adminsInclude(Session.user()) or
        ((discussion.group().membersCanAnnounce or discussion.group().membersCanAddGuests) and discussion.membersInclude(Session.user()))
      perform: ->
        EventBus.$emit 'openModal',
          component: 'StrandMembersList',
          props: { discussion: discussion }

    react:
      canPerform: -> AbilityService.canAddComment(discussion)

    edit_tags:
      icon: 'mdi-tag-outline'
      name: 'loomio_tags.card_title'
      canPerform: -> AbilityService.canEditThread(discussion)
      perform: ->
        openModal
          component: 'TagsModal',
          props: { model: discussion.clone() }

    add_comment:
      icon: 'mdi-reply'
      canPerform: -> AbilityService.canAddComment(discussion)
      perform: -> vm.$vuetify.goTo('#add-comment')

    show_history:
      icon: 'mdi-history'
      name: 'action_dock.show_edits'
      canPerform: -> discussion.edited()
      perform: ->
        openModal
          component: 'RevisionHistoryModal'
          props:
            model: discussion

    edit_thread:
      name: 'common.action.edit'
      icon: 'mdi-pencil'
      canPerform: -> AbilityService.canEditThread(discussion)
      to: ->
        "/d/#{discussion.key}/edit"
      perform: ->
        Records.discussions.remote.fetchById(discussion.key, {exclude_types: 'group user poll event'}).then ->
          openModal
            component: 'DiscussionForm',
            props:
              discussion: discussion.clone()

    edit_arrangement:
      icon: 'mdi-directions-fork'
      canPerform: -> AbilityService.canEditThread(discussion)
      perform: ->
        openModal
          component: 'ArrangementForm',
          props:
            discussion: discussion.clone()

    translate_thread:
      icon: 'mdi-translate'
      name: 'common.action.translate'
      menu: true
      canPerform: -> AbilityService.canTranslate(discussion)
      perform: -> Session.user() && discussion.translate(Session.user().locale)

    close_thread:
      menu: true
      canPerform: -> !discussion.closedAt
      perform: => @close(discussion)

    reopen_thread:
      menu: true
      canPerform: -> AbilityService.canReopenThread(discussion)
      perform: => @reopen(discussion)

    move_thread:
      menu: true
      canPerform: -> AbilityService.canMoveThread(discussion)
      perform: ->
        openModal
          component: 'MoveThreadForm'
          props: { discussion: discussion.clone() }

    # delete_thread:
    #   menu: true
    #   canPerform: -> AbilityService.canDeleteThread(discussion)
    #   perform: ->
    #     openModal
    #       component: 'ConfirmModal',
    #       props:
    #         confirm:
    #           submit: discussion.destroy
    #           text:
    #             title: 'delete_thread_form.title'
    #             helptext: 'delete_thread_form.body'
    #             submit: 'delete_thread_form.confirm'
    #             flash: 'delete_thread_form.messages.success'
    #           redirect: LmoUrlService.group discussion.group()

    discard_thread:
      name: 'action_dock.delete_thread'
      menu: true
      canPerform: -> AbilityService.canDeleteThread(discussion)
      perform: ->
        openModal
          component: 'ConfirmModal',
          props:
            confirm:
              submit: discussion.discard
              text:
                title: 'delete_thread_form.title'
                helptext: 'delete_thread_form.body'
                submit: 'delete_thread_form.confirm'
                flash: 'delete_thread_form.messages.success'
              redirect: LmoUrlService.group discussion.group()

  mute: (thread, override = false) ->
    if !Session.user().hasExperienced("mutingThread") and !override
      Records.users.saveExperience("mutingThread")
      Records.users.updateProfile(Session.user()).then ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit: -> thread.saveVolume('mute', true)
              text:
                title: 'mute_explanation_modal.mute_thread'
                flash: 'discussion.volume.mute_message'
                fragment: 'mute_thread'
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
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit: thread.close
              text:
                title: 'close_explanation_modal.close_thread'
                helptext: 'close_explanation_modal.body'
                flash: 'discussion.closed.closed'
    else
      thread.close().then =>
        Flash.success "discussion.closed.closed", {}, 'undo', => @reopen(thread)

  reopen: (thread) ->
    thread.reopen().then =>
      Flash.success "discussion.closed.reopened", {}, 'undo', => @close(thread)

  dismiss: (thread) ->
    if !Session.user().hasExperienced("dismissThread")
      Records.users.saveExperience("dismissThread")
      openModal
        component: 'ConfirmModal'
        props:
          confirm:
            submit: => @dismiss(thread)
            text:
              title: 'dismiss_explanation_modal.dismiss_thread'
              helptext: 'dismiss_explanation_modal.body_html'
              submit: 'dismiss_explanation_modal.dismiss_thread'
              flash: 'dashboard_page.thread_dismissed'
    else
      thread.dismiss().then =>
        Flash.success "dashboard_page.thread_dismissed", {}, 'undo', => @recall(thread)

  recall: (thread) ->
    thread.recall().then =>
      Flash.success "dashboard_page.thread_recalled", {}, 'undo', => @dismiss(thread)

  pin: (thread) ->
    if !Session.user().hasExperienced("pinningThread")
      Records.users.saveExperience("pinningThread").then ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit: thread.savePin
              text:
                title: 'pin_thread_modal.title'
                flash: 'discussion.pin.pinned'
                helptext: 'pin_thread_modal.helptext'
    else
      thread.savePin().then =>
        Flash.success "discussion.pin.pinned", 'undo', => @unpin(thread)

  unpin: (thread) ->
    thread.savePin().then =>
      Flash.success "discussion.pin.unpinned", 'undo', => @pin(thread)
