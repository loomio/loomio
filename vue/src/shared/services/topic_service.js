import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import Flash         from '@/shared/services/flash';
import EventBus      from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import { subMonths } from 'date-fns';

export default new class TopicService {
  actions(topic) {
    return {
      subscribe: {
        name: 'common.action.subscribe',
        icon: 'mdi-bell',
        menu: true,
        canPerform() {
          return !topic.closedAt &&
          (topic.volume() === 'normal') &&
          AbilityService.canChangeVolume(topic);
        },
        perform() {
          return openModal({
            component: 'ChangeVolumeForm',
            props: { model: topic }
          });
        }
      },

      unsubscribe: {
        name: 'common.action.unsubscribe',
        icon: 'mdi-bell-off',
        menu: true,
        canPerform() {
          return (topic.volume() === 'loud') && AbilityService.canChangeVolume(topic);
        },
        perform() {
          return openModal({
            component: 'ChangeVolumeForm',
            props: { model: topic }
          });
        }
      },

      unignore: {
        name: 'common.action.unignore',
        icon: 'mdi-bell-outline',
        dock: 2,
        canPerform() {
          return (topic.volume() === 'quiet') && AbilityService.canChangeVolume(topic);
        },
        perform() {
          return openModal({
            component: 'ChangeVolumeForm',
            props: { model: topic }
          });
        }
      },

      announce_thread: {
        name: 'common.action.invite',
        icon: 'mdi-bullhorn',
        dock: 3,
        canPerform() {
          return topic.group().adminsInclude(Session.user()) ||
          ((topic.group().membersCanAnnounce || topic.group().membersCanAddGuests) && topic.membersInclude(Session.user()));
        },
        perform() {
          return EventBus.$emit('openModal', {
            component: 'StrandMembersList',
            props: { topic }
          });
        }
      },

      pin_thread: {
        icon: 'mdi-pin-outline',
        name: 'action_dock.pin_discussion',
        menu: true,
        canPerform() { return AbilityService.canPinThread(topic); },
        perform: () => this.pin(topic)
      },

      unpin_thread: {
        icon: 'mdi-pin-off',
        name: 'action_dock.unpin_discussion',
        menu: true,
        canPerform() { return AbilityService.canUnpinThread(topic); },
        perform: () => this.unpin(topic)
      },

      dismiss_thread: {
        name: 'dashboard_page.mark_as_read',
        icon: 'mdi-check',
        dock: 1,
        canPerform() { return topic.isUnread(); },
        perform: () => this.dismiss(topic)
      },

      edit_arrangement: {
        icon: (topic.newestFirst && 'mdi-arrow-up') || 'mdi-arrow-down',
        name: (topic.newestFirst && 'strand_nav.newest_first') || 'strand_nav.oldest_first',
        canPerform() { return topic.adminsInclude(Session.user()); },
        perform() {
          return openModal({
            component: 'ArrangementForm',
            props: { topic: topic.clone() }
          });
        }
      },

      close_thread: {
        name: 'action_dock.close_discussion',
        menu: true,
        icon: 'mdi-archive-outline',
        canPerform() { return AbilityService.canCloseThread(topic); },
        perform: () => this.close(topic)
      },

      reopen_thread: {
        name: 'action_dock.reopen_discussion',
        menu: true,
        icon: 'mdi-refresh',
        dock: 2,
        canPerform() { return AbilityService.canReopenThread(topic); },
        perform: () => this.reopen(topic)
      },

      move_thread: {
        menu: true,
        icon: 'mdi-arrow-right',
        canPerform() { return AbilityService.canMoveThread(topic); },
        perform() {
          return openModal({
            component: 'MoveThreadForm',
            props: { topic: topic.clone() }
          });
        }
      },

      discard_thread: {
        name: 'action_dock.delete_discussion',
        icon: 'mdi-delete-outline',
        menu: true,
        canPerform() { return AbilityService.canDeleteThread(topic); },
        perform() {
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit: topic.discard,
                text: {
                  title: 'action_dock.delete_discussion',
                  helptext: 'delete_discussion_form.body',
                  submit: 'action_dock.delete_discussion',
                  flash: 'delete_discussion_form.discussion_deleted'
                },
                redirect: LmoUrlService.group(topic.group())
              }
            }
          });
        }
      }
    };
  }

  mute(topic, override) {
    if (override == null) { override = false; }
    if (!Session.user().hasExperienced("mutingThread") && !override) {
      Records.users.saveExperience("mutingThread");
      return Records.users.updateProfile(Session.user()).then(() => openModal({
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit() { return topic.saveVolume('mute', true); },
            text: {
              title: 'mute_explanation_modal.mute_thread',
              flash: 'discussion.volume.mute_message',
              fragment: 'mute_thread'
            }
          }
        }
      }));
    } else {
      const previousVolume = topic.volume();
      return topic.saveVolume('mute').then(() => {
        return Flash.success("discussion.volume.mute_message",
          {name: topic.title}
        , 'undo', () => this.unmute(topic, previousVolume));
      });
    }
  }

  unmute(topic, previousVolume) {
    if (previousVolume == null) { previousVolume = 'normal'; }
    return topic.saveVolume(previousVolume).then(() => {
      return Flash.success("discussion.volume.unmute_message",
        {name: topic.title}
      , 'undo', () => this.mute(topic));
    });
  }

  close(topic) {
    if (!Session.user().hasExperienced("closingThread")) {
      Records.users.saveExperience("closingThread");
      return Records.users.updateProfile(Session.user()).then(() => openModal({
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: topic.close,
            text: {
              title: 'action_dock.close_discussion',
              helptext: 'close_discussion_modal.body',
              flash: 'discussion.closed.closed'
            }
          }
        }
      }));
    } else {
      return topic.close().then(() => {
        return Flash.success("discussion.closed.closed");
      });
    }
  }

  reopen(topic) {
    return topic.reopen().then(() => {
      return Flash.success("discussion.closed.reopened");
    });
  }

  dismiss(topic) {
    return topic.dismiss().then(() => {
      return Flash.success("dashboard_page.discussion_marked_as_read", {}, 'undo', () => this.recall(topic));
    });
  }

  recall(topic) {
    return topic.recall().then(() => {
      return Flash.success("dashboard_page.discussion_marked_as_unread", {}, 'undo', () => this.dismiss(topic));
    });
  }

  pin(topic) {
    if (!Session.user().hasExperienced("pinningThread")) {
      return Records.users.saveExperience("pinningThread").then(() => openModal({
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: topic.savePin,
            text: {
              title: 'action_dock.pin_discussion',
              flash: 'discussion.pin.pinned',
              helptext: 'pin_discussion_modal.helptext'
            }
          }
        }
      }));
    } else {
      return topic.savePin().then(() => {
        return Flash.success("discussion.pin.pinned", 'undo', () => this.unpin(topic));
      });
    }
  }

  unpin(topic) {
    return topic.saveUnpin().then(() => {
      return Flash.success("discussion.pin.unpinned", 'undo', () => this.pin(topic));
    });
  }
};
