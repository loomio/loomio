import Session       from '@/shared/services/session'
import Records       from '@/shared/services/records'
import Flash         from '@/shared/services/flash'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'

export default new class PollService
  actions: (poll, vm) ->
    edit_poll:
      canPerform: ->
        AbilityService.canEditPoll(poll)
      perform: ->
        openModal
          component: 'PollCommonModal'
          props:
            poll: poll.clone()

    close_poll:
      canPerform: ->
        AbilityService.canClosePoll(poll)
      perform: ->
        openModal
          component: 'ConfirmModal',
          props:
            confirm:
              submit: -> poll.close()
              successCallback: ->
                openModal
                  component: 'PollCommonOutcomeModal'
                  props:
                    outcome: Records.outcomes.build(pollId: poll.id)
              text:
                title:    'poll_common_close_form.title'
                helptext: 'poll_common_close_form.helptext'
                confirm:  'poll_common_close_form.close_poll'
                flash:    'poll_common_close_form.poll_closed'

    reopen_poll:
      canPerform: ->
        AbilityService.canReopenPoll(poll)
      perform: ->
        openModal
          component: 'PollCommonReopenModal'
          props: { poll: poll }

    export_poll:
      canPerform: ->
        AbilityService.canExportPoll(poll)
      perform: ->
        exportPath = LmoUrlService.poll(poll, {}, action:'export', absolute:true)
        LmoUrlService.goTo(exportPath,true)

    delete_poll:
      canPerform: ->
        AbilityService.canDeletePoll(poll)
      perform: ->
        openModal
          component: 'ConfirmModal'
          props:
            confirm:
              submit: -> poll.destroy()
              text:
                title:    'poll_common_delete_modal.title'
                confirm:  'poll_common_delete_modal.question'
                flash:    'poll_common_delete_modal.success'

    pin_event:
      icon: 'mdi-pin'
      canPerform: ->
        AbilityService.canPinEvent(poll.createdEvent())
      perform: ->
        poll.createdEvent().pin().then ->
          Flash.success('activity_card.event_pinned')

    unpin_event:
      icon: 'mdi-pin-off'
      canPerform: ->
        AbilityService.canUnpinEvent(poll.createdEvent())
      perform: ->
        poll.createdEvent().unpin().then ->
          Flash.success('activity_card.event_unpinned')
