import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import Flash         from '@/shared/services/flash';
import EventBus      from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import ScrollService  from '@/shared/services/scroll_service';
import openModal      from '@/shared/helpers/open_modal';
import { hardReload } from '@/shared/helpers/window';
import { subMonths } from 'date-fns';

export default new class TopicService {
  actions(topic) {
    return {
      subscribe: {
        name: 'common.action.subscribe',
        icon: 'mdi-bell',
        canPerform() {
          return !topic.closedAt &&
          (topic.volume() === 'normal') &&
          topic.membersInclude(Session.user());
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
        canPerform() {
          return (topic.volume() === 'loud') && topic.membersInclude(Session.user());
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
        canPerform() {
          return (topic.volume() === 'quiet') && topic.membersInclude(Session.user());
        },
        perform() {
          return openModal({
            component: 'ChangeVolumeForm',
            props: { model: topic }
          });
        }
      },

      start_vote: {
        name: 'activity_card.start_a_vote',
        icon: 'mdi-thumbs-up-down-outline',
        collection: 'actions',
        canPerform() {
          return AbilityService.canStartPoll(topic);
        },
        perform() {
          EventBus.$emit('show-add-poll-form');
          ScrollService.scrollTo('#add-comment');
        }
      },

      add_comment: {
        name: 'comment_form.add_a_comment',
        icon: 'mdi-comment-outline',
        dockDisplay: 'icon',
        collection: 'actions',
        canPerform() {
          return AbilityService.canAddComment(topic);
        },
        perform() {
          EventBus.$emit('show-add-comment-form');
          ScrollService.scrollTo('#add-comment');
          document.querySelector('#add-comment').focus();
        }
      },

      announce_thread: {
        name: 'common.action.invite',
        icon: 'mdi-account-multiple-plus',
        dock: 3,
        collection: 'members',
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

      seen_by: {
        name: 'discussion_context.seen_by_count',
        nameArgs: () => ({count: topic.seenByCount}),
        icon: 'mdi-eye-outline',
        collection: 'members',
        canPerform() { return topic.seenByCount > 0; },
        perform() {
          return openModal({
            component: 'SeenByModal',
            persistent: false,
            props: { topic }
          });
        }
      },

      users_notified: {
        name: 'discussion_context.count_notified',
        nameArgs: () => ({count: topic.usersNotifiedCount}),
        icon: 'mdi-bullhorn-outline',
        collection: 'members',
        canPerform() { return !!topic.usersNotifiedCount; },
        perform() {
          return openModal({
            component: 'AnnouncementHistory',
            persistent: false,
            props: { model: topic }
          });
        }
      },

      pin_thread: {
        icon: 'mdi-pin-outline',
        name: 'action_dock.pin_thread',
        canPerform() {
          return !topic.closedAt && !topic.pinnedAt && (
            topic.adminsInclude(Session.user()) ||
            (topic.group().membersCanEditDiscussions && topic.membersInclude(Session.user()))
          );
        },
        perform: () => this.pin(topic)
      },

      unpin_thread: {
        icon: 'mdi-pin-off',
        name: 'action_dock.unpin_thread',
        canPerform() {
          return topic.pinnedAt && (
            topic.adminsInclude(Session.user()) ||
            (topic.group().membersCanEditDiscussions && topic.membersInclude(Session.user()))
          );
        },
        perform: () => this.unpin(topic)
      },

      dismiss_thread: {
        name: 'dashboard_page.mark_as_read',
        icon: 'mdi-check',
        dock: 1,
        canPerform() { return topic.isUnread(); },
        perform: () => this.dismiss(topic)
      },

      export_thread: {
      name: 'common.action.print',
        icon: 'mdi-printer-outline',
        dock: 0,
        collection: 'actions',
        canPerform() {
          return !topic.discardedAt && topic.membersInclude(Session.user());
        },
        perform() {
          const topicable = topic.topicable();
          if (topicable.isA('poll')) {
            return hardReload(LmoUrlService.poll(topicable, {export: 1}, {action: 'export', ext: 'html', absolute: true}));
          } else {
            return hardReload(LmoUrlService.discussion(topicable, {export: 1}, {absolute: true, print: true}));
          }
        }
      },

      move_thread: {
        name: 'action_dock.move_thread',
        collection: 'actions',
        icon: 'mdi-file-move-outline',
        canPerform() { return AbilityService.canMoveTopic(topic); },
        perform() {
          return openModal({
            component: 'MoveThreadForm',
            props: { topic: topic.clone() }
          });
        }
      },


      thread_settings: {
        name: 'thread_arrangement_form.thread_settings',
        icon: 'mdi-cog-outline',
        collection: 'actions',
        canPerform() {
          return topic && topic.adminsInclude(Session.user());
        },
        perform() {
          return openModal({
            component: 'TopicForm',
            props: { topic: topic.clone() }
          });
        }
      },

      close_thread: {
        name: 'action_dock.close_thread',
        collection: 'actions',
        icon: 'mdi-archive-outline',
        canPerform() {
          return !topic.closedAt && (
            topic.adminsInclude(Session.user()) ||
            (topic.group().membersCanEditDiscussions && topic.membersInclude(Session.user()))
          );
        },
        perform: () => this.close(topic)
      },

      reopen_thread: {
        name: 'action_dock.reopen_thread',
        collection: 'actions',
        icon: 'mdi-refresh',
        dock: 2,
        canPerform() {
          return topic.closedAt && (
            topic.adminsInclude(Session.user()) ||
            (topic.group().membersCanEditDiscussions && topic.membersInclude(Session.user()))
          );
        },
        perform: () => this.reopen(topic)
      },


      discard_thread: {
        name: 'action_dock.delete_thread',
        icon: 'mdi-delete-outline',
        collection: 'actions',
        canPerform() {
          return topic.adminsInclude(Session.user()) || (topic.author() === Session.user());
        },
        perform() {
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit: topic.discard,
                text: {
                  title: 'action_dock.delete_thread',
                  helptext: 'delete_discussion_form.body',
                  submit: 'action_dock.delete_thread',
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
          {name: topic.topicable().title}
        , 'undo', () => this.unmute(topic, previousVolume));
      });
    }
  }

  unmute(topic, previousVolume) {
    if (previousVolume == null) { previousVolume = 'normal'; }
    return topic.saveVolume(previousVolume).then(() => {
      return Flash.success("discussion.volume.unmute_message",
        {name: topic.topicable().title}
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
