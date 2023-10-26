/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let EventService;
import AbilityService from '@/shared/services/ability_service';
import Flash from '@/shared/services/flash';
import openModal from '@/shared/helpers/open_modal';
import LmoUrlService  from '@/shared/services/lmo_url_service';

export default new (EventService = class EventService {
  actions(event, vm) {
    return {
      move_event: {
        name: 'action_dock.move_item',
        menu: true,
        icon: 'mdi-call-split',
        kinds: ['new_discussion', 'poll_created', 'new_comment'],
        perform() {
          return event.discussion().forkedEventIds.push(event.id);
        },
        canPerform() {
          return !event.model().discardedAt &&
          !event.discussion().closedAt &&
          AbilityService.canMoveThread(event.discussion());
        }
      },

      pin_event: {
        name: 'action_dock.pin_event',
        icon: 'mdi-pin-outline',
        menu: true,
        kinds: ['new_comment', 'poll_created'],
        canPerform() { return !event.model().discardedAt && AbilityService.canPinEvent(event); },
        perform() {
          return openModal({
            component: 'PinEventForm',
            props: { event }});
        }
      },

      unpin_event: {
        name: 'action_dock.unpin_event',
        icon: 'mdi-pin-off',
        menu: true,
        kinds: ['new_comment', 'poll_created'],
        canPerform() { return !event.model().discardedAt && AbilityService.canUnpinEvent(event); },
        perform() { return event.unpin().then(() => Flash.success('activity_card.event_unpinned')); }
      },

      copy_url: {
        icon: 'mdi-link',
        menu: true,
        kinds: ['new_comment', 'poll_created', 'stance_created', 'stance_updated'],
        canPerform() { return !event.model().discardedAt; },
        perform() {
          const link = LmoUrlService.event(event, {}, {absolute: true});
          return navigator.clipboard.writeText(link).then(() => Flash.success("action_dock.url_copied"));
        }
      }
    };
  }
});
