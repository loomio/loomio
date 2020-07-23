import AbilityService from '@/shared/services/ability_service'
import Flash from '@/shared/services/flash'
import openModal from '@/shared/helpers/open_modal'
import LmoUrlService  from '@/shared/services/lmo_url_service'

export default new class EventService
  actions: (event, vm) ->
    move_event:
      name: 'action_dock.move_item'
      perform: ->
        event.toggleFromFork()

      canPerform: ->
        !event.model().discardedAt && AbilityService.canMoveThread(event.discussion())

    remove_event:
      perform: ->
        event.removeFromThread().then ->
          Flash.success 'thread_item.event_removed'

      canPerform: ->
        !event.model().discardedAt &&
        event.kind == 'discussion_edited' &&
        AbilityService.canAdminister(event.discussion())

    pin_event:
      name: 'common.action.pin'
      icon: 'mdi-pin'
      canPerform: -> !event.model().discardedAt && AbilityService.canPinEvent(event)
      perform: ->
        openModal
          component: 'PinEventForm',
          props: { event: event }

    unpin_event:
      name: 'common.action.unpin'
      icon: 'mdi-pin-off'
      canPerform: -> !event.model().discardedAt && AbilityService.canUnpinEvent(event)
      perform: -> event.unpin().then -> Flash.success('activity_card.event_unpinned')


    copy_url:
      icon: 'mdi-link'
      canPerform: -> !event.model().discardedAt
      perform:    ->
        link = LmoUrlService.event(event, {}, absolute: true)
        vm.$copyText(link).then (e) ->
          Flash.success("action_dock.url_copied")
