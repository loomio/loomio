import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import Flash         from '@/shared/services/flash';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import { hardReload } from '@/shared/helpers/window';
import { subMonths } from 'date-fns';

export default new class TopicService {
  actions(topic, vm) {
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
            props: {
              model: topic
            }
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
            props: {
              model: topic
            }
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
            props: {
              model: topic
            }
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
        canPerform() { return AbilityService.canPinThread(discussion); },
        perform: () => this.pin(discussion)
      },

      unpin_thread: {
        icon: 'mdi-pin-off',
        name: 'action_dock.unpin_discussion',
        menu: true,
        canPerform() { return AbilityService.canUnpinThread(discussion); },
        perform: () => this.unpin(discussion)
      },

      dismiss_thread: {
        name: 'dashboard_page.mark_as_read',
        icon: 'mdi-check',
        dock: 1,
        canPerform() { return discussion.isUnread(); },
        perform: () => this.dismiss(discussion)
      },

      edit_arrangement: {
        icon: (topic.newestFirst && 'mdi-arrow-up') || 'mdi-arrow-down',
        name: (topic.newestFirst && 'strand_nav.newest_first') || 'strand_nav.oldest_first',
        canPerform() { return AbilityService.canEditThread(topic); },
        perform() {
          return openModal({
            component: 'ArrangementForm',
            props: {
              topic: topic.clone()
            }
          });
        }
      },

      close_thread: {
        name: 'action_dock.close_discussion',
        menu: true,
        icon: 'mdi-archive-outline',
        canPerform() { return AbilityService.canCloseThread(discussion); },
        perform: () => this.close(discussion)
      },

      reopen_thread: {
        name: 'action_dock.reopen_discussion',
        menu: true,
        icon: 'mdi-refresh',
        dock: 2,
        canPerform() { return AbilityService.canReopenThread(discussion); },
        perform: () => this.reopen(discussion)
      },

      move_thread: {
        menu: true,
        icon: 'mdi-arrow-right',
        canPerform() { return AbilityService.canMoveThread(discussion); },
        perform() {
          return openModal({
            component: 'MoveThreadForm',
            props: { discussion: discussion.clone() }});
        }
      },

      // delete_thread:
      //   menu: true
      //   canPerform: -> AbilityService.canDeleteThread(discussion)
      //   perform: ->
      //     openModal
      //       component: 'ConfirmModal',
      //       props:
      //         confirm:
      //           submit: discussion.destroy
      //           text:
      //             title: 'delete_thread_form.title'
      //             helptext: 'delete_thread_form.body'
      //             submit: 'delete_thread_form.confirm'
      //             flash: 'delete_thread_form.messages.success'
      //           redirect: LmoUrlService.group discussion.group()

      discard_thread: {
        name: 'action_dock.delete_discussion',
        icon: 'mdi-delete-outline',
        menu: true,
        canPerform() { return AbilityService.canDeleteThread(discussion); },
        perform() {
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit: discussion.discard,
                text: {
                  title: 'action_dock.delete_discussion',
                  helptext: 'delete_discussion_form.body',
                  submit: 'action_dock.delete_discussion',
                  flash: 'delete_discussion_form.discussion_deleted'
                },
                redirect: LmoUrlService.group(discussion.group())
              }
            }
          });
        }
      }
    };
  }

  dashboardQuery() {
    const groupIds = Records.memberships.collection.find({userId: Session.user().id}).map(m => m.groupId);
    let chain = Records.discussions.collection.chain();
    chain = chain.find({$or: [{groupId: {$in: groupIds}}, {discussionReaderUserId: Session.user().id, revokedAt: null, inviterId: {$ne: null}}]});
    chain = chain.find({discardedAt: null});
    chain = chain.find({closedAt: null});
    chain = chain.find({lastActivityAt: { $gt: subMonths(new Date(), 6) }});
    chain = chain.simplesort('lastActivityAt', true);
    return chain.data();
  }

  groupDiscussionsQuery(group, groupIds, t, tag, page, loader) {
    if (!group) { return; }


    let pinnedDiscussions = []
    if (page == 1 && !t && !tag) {
      pinnedDiscussions = Records.discussions.collection.chain().find({
        discardedAt: null,
        groupId: group.id,
        pinnedAt: {$ne: null}
      }).simplesort('pinnedAt', true).data();
    }

    let chain = Records.discussions.collection.chain().find({
      discardedAt: null,
      groupId: {$in: groupIds},
      id: {$nin: pinnedDiscussions.map(d => d.id)}
    }).simplesort('lastActivityAt', true);

    switch (t) {
      case 'unread':
        chain = chain.where(discussion => discussion.isUnread());
        break;
      case 'closed':
        chain = chain.find({closedAt: {$ne: null}});
        break;
      case 'all':
        break;
      default:
        chain = chain.find({closedAt: null});
    }

    if (tag) {
      const tag = Records.tags.find({groupId: group.parentOrSelf().id, name: tag})[0];
      chain = chain.find({tagIds: {'$contains': tag.id}});
    }

    let discussions = []
    if (loader.pageWindow[page]) {
      if (page === 1) {
        chain = chain.find({lastActivityAt: {$gte: loader.pageWindow[page][0]}});
      } else {
        chain = chain.find({lastActivityAt: {$jbetween: loader.pageWindow[page]}});
      }
      discussions = chain.data();
    }
    return pinnedDiscussions.concat(discussions);
  }

  mute(thread, override) {
    if (override == null) { override = false; }
    if (!Session.user().hasExperienced("mutingThread") && !override) {
      Records.users.saveExperience("mutingThread");
      return Records.users.updateProfile(Session.user()).then(() => openModal({
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit() { return thread.saveVolume('mute', true); },
            text: {
              title: 'mute_explanation_modal.mute_thread',
              flash: 'discussion.volume.mute_message',
              fragment: 'mute_thread'
            }
          }
        }
      }));
    } else {
      const previousVolume = thread.volume();
      return thread.saveVolume('mute').then(() => {
        return Flash.success("discussion.volume.mute_message",
          {name: thread.title}
        , 'undo', () => this.unmute(thread, previousVolume));
      });
    }
  }

  unmute(thread, previousVolume) {
    if (previousVolume == null) { previousVolume = 'normal'; }
    return thread.saveVolume(previousVolume).then(() => {
      return Flash.success("discussion.volume.unmute_message",
        {name: thread.title}
      , 'undo', () => this.mute(thread));
    });
  }

  close(thread) {
    if (!Session.user().hasExperienced("closingThread")) {
      Records.users.saveExperience("closingThread");
      return Records.users.updateProfile(Session.user()).then(() => openModal({
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: thread.close,
            text: {
              title: 'action_dock.close_discussion',
              helptext: 'close_discussion_modal.body',
              flash: 'discussion.closed.closed'
            }
          }
        }
      }));
    } else {
      return thread.close().then(() => {
        return Flash.success("discussion.closed.closed");
      });
    }
  }

  reopen(thread) {
    return thread.reopen().then(() => {
      return Flash.success("discussion.closed.reopened");
    });
  }

  dismiss(thread) {
    return thread.dismiss().then(() => {
      return Flash.success("dashboard_page.discussion_marked_as_read", {}, 'undo', () => this.recall(thread));
    });
  }

  recall(thread) {
    return thread.recall().then(() => {
      return Flash.success("dashboard_page.discussion_marked_as_unread", {}, 'undo', () => this.dismiss(thread));
    });
  }

  pin(thread) {
    if (!Session.user().hasExperienced("pinningThread")) {
      return Records.users.saveExperience("pinningThread").then(() => openModal({
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: thread.savePin,
            text: {
              title: 'action_dock.pin_discussion',
              flash: 'discussion.pin.pinned',
              helptext: 'pin_discussion_modal.helptext'
            }
          }
        }
      }));
    } else {
      return thread.savePin().then(() => {
        return Flash.success("discussion.pin.pinned", 'undo', () => this.unpin(thread));
      });
    }
  }

  unpin(thread) {
    return thread.saveUnpin().then(() => {
      return Flash.success("discussion.pin.unpinned", 'undo', () => this.pin(thread));
    });
  }
};
