import AbilityService from '@/shared/services/ability_service'
import Flash from '@/shared/services/flash'
import openModal from '@/shared/helpers/open_modal'
import LmoUrlService  from '@/shared/services/lmo_url_service'

export default new class EventService
  actions: (event, vm) ->
    move_event:
      name: 'action_dock.move_item'
      menu: true
      kinds: ['new_discussion']
      perform: ->
        event.discussion().forkedEventIds.push(event.id)
      canPerform: ->
        !event.model().discardedAt && AbilityService.canMoveThread(event.discussion())

    pin_event:
      name: 'action_dock.pin_event'
      icon: 'mdi-pin-outline'
      menu: true
      kinds: ['new_comment', 'poll_created']
      canPerform: -> !event.model().discardedAt && AbilityService.canPinEvent(event)
      perform: ->
        openModal
          component: 'PinEventForm',
          props: { event: event }

    unpin_event:
      name: 'action_dock.unpin_event'
      icon: 'mdi-pin-off'
      menu: true
      kinds: ['new_comment', 'poll_created']
      canPerform: -> !event.model().discardedAt && AbilityService.canUnpinEvent(event)
      perform: -> event.unpin().then -> Flash.success('activity_card.event_unpinned')

    copy_url:
      icon: 'mdi-link'
      menu: true
      kinds: ['new_comment', 'poll_created', 'stance_created', 'stance_updated']
      canPerform: -> !event.model().discardedAt
      perform:    ->
        link = LmoUrlService.event(event, {}, absolute: true)
        vm.$copyText(link).then (e) ->
          Flash.success("action_dock.url_copied")
