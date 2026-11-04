import AbilityService from '@/shared/services/ability_service';
import Flash from '@/shared/services/flash';
import openModal from '@/shared/helpers/open_modal';
import LmoUrlService  from '@/shared/services/lmo_url_service';

export default new class TopicItemService {
  actions(topic_item, vm) {
    return {
      edit_item_tags: {
        name: 'loomio_tags.apply_tags',
        icon: 'mdi-tag-outline',
        menu: true,
        canPerform() { return AbilityService.canTagTopicItem(topic_item); },
        perform() {
          return openModal({component: 'TopicTagsDialog', props: {topic: topic_item.topic(), topicItem: topic_item}});
        }
      },
      move_event: {
        name: 'action_dock.move_item',
        menu: true,
        icon: 'mdi-call-split',
        kinds: ['new_discussion', 'poll_created', 'new_comment'],
        perform() {
          const topic = topic_item.topic();
          if (topic) { topic.selectedTopicItemIds.push(topic_item.id); }
        },
        canPerform() {
          const topic = topic_item.topic();
          return topic &&
          !topic_item.model().discardedAt &&
          !topic.lockedAt &&
          AbilityService.canMoveTopicItems(topic);
        }
      },

      pin_event: {
        name: 'action_dock.add_to_timeline',
        icon: 'mdi-timeline-plus-outline',
        menu: true,
        kinds: ['new_comment', 'poll_created'],
        canPerform() { return !topic_item.model().discardedAt && AbilityService.canPinEvent(topic_item); },
        perform() {
          return openModal({
            component: 'PinEventForm',
            props: { topic_item }});
        }
      },

      unpin_event: {
        name: 'action_dock.remove_from_timeline',
        icon: 'mdi-timeline-remove-outline',
        menu: true,
        kinds: ['new_comment', 'poll_created'],
        canPerform() { return !topic_item.model().discardedAt && AbilityService.canUnpinEvent(topic_item); },
        perform() { return topic_item.unpin().then(() => Flash.success('activity_card.event_unpinned')); }
      },

      copy_url: {
        icon: 'mdi-link',
        menu: true,
        kinds: ['new_comment', 'poll_created', 'stance_created', 'stance_updated'],
        canPerform() { return !topic_item.model().discardedAt; },
        perform() {
          const link = LmoUrlService.topic_item(topic_item, {}, {absolute: true});
          return navigator.clipboard.writeText(link).then(() => Flash.success("action_dock.url_copied"));
        }
      }
    };
  }
};
