import AbilityService from '@/shared/services/ability_service'
import Flash from '@/shared/services/flash'
import openModal from '@/shared/helpers/open_modal'

export default new class EventService
  actions: (event, vm) ->
    move_event:
      name: 'action_dock.move_items'
      perform: ->
        event.toggleFromFork()

      canPerform: ->
        AbilityService.canMoveThread(event.discussion())

    remove_event:
      perform: ->
        event.removeFromThread().then ->
          Flash.success 'thread_item.event_removed'

      canPerform: ->
        event.kind == 'discussion_edited' &&
        AbilityService.canAdministerDiscussion(event.discussion())

    pin_event:
      name: 'action_dock.pin_event'
      icon: 'mdi-pin'
      canPerform: -> AbilityService.canPinEvent(event)
      perform: -> event.pin().then -> Flash.success('activity_card.event_pinned')

    unpin_event:
      name: 'action_dock.unpin_event'
      icon: 'mdi-pin-off'
      canPerform: -> AbilityService.canUnpinEvent(event)
      perform: -> event.unpin().then -> Flash.success('activity_card.event_unpinned')
