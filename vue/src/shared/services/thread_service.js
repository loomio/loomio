import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import Flash         from '@/shared/services/flash';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import { hardReload } from '@/shared/helpers/window';

export default new class ThreadService {
  actions(discussion, vm) {
    return {
      make_a_copy: {
        icon: 'mdi-content-copy',
        name: 'templates.make_a_copy',
        menu: true,
        canPerform() { return Session.user(); },
        to() { return `/d/new?discussion_id=${discussion.id}`; }
      },

      translate_thread: {
        icon: 'mdi-translate',
        name: 'common.action.translate',
        dock: 2,
        canPerform() { return AbilityService.canTranslate(discussion); },
        perform() { return Session.user() && discussion.translate(Session.user().locale); }
      },

      subscribe: {
        name: 'common.action.subscribe',
        icon: 'mdi-bell',
        dock: 2,
        canPerform() {
          return !discussion.closedAt &&
          (discussion.volume() === 'normal') &&
          AbilityService.canChangeVolume(discussion);
        },
        perform() {
          return openModal({
            component: 'ChangeVolumeForm',
            props: {
              model: discussion
            }
          });
        }
      },

      unsubscribe: {
        name: 'common.action.unsubscribe',
        icon: 'mdi-bell-off',
        dock: 2,
        canPerform() {
          return (discussion.volume() === 'loud') && AbilityService.canChangeVolume(discussion);
        },
        perform() {
          return openModal({
            component: 'ChangeVolumeForm',
            props: {
              model: discussion
            }
          });
        }
      },

      unignore: {
        name: 'common.action.unignore',
        icon: 'mdi-bell-outline',
        dock: 2,
        canPerform() {
          return (discussion.volume() === 'quiet') && AbilityService.canChangeVolume(discussion);
        },
        perform() {
          return openModal({
            component: 'ChangeVolumeForm',
            props: {
              model: discussion
            }
          });
        }
      },

      announce_thread: {
        name: 'common.action.invite',
        icon: 'mdi-send',
        dock: 2,
        canPerform() {
          return discussion.group().adminsInclude(Session.user()) ||
          ((discussion.group().membersCanAnnounce || discussion.group().membersCanAddGuests) && discussion.membersInclude(Session.user()));
        },
        perform() {
          return EventBus.$emit('openModal', {
            component: 'StrandMembersList',
            props: { discussion }
          });
        }
      },

      react: {
        dock: 1,
        canPerform() { return AbilityService.canAddComment(discussion); }
      },

      add_comment: {
        icon: 'mdi-reply',
        dockDisplay: 'icon',
        dock: 1,
        canPerform() { return AbilityService.canAddComment(discussion); },
        perform() { return vm.$vuetify.goTo('#add-comment'); }
      },

      edit_thread: {
        name: 'common.action.edit',
        icon: 'mdi-pencil',
        dock: 1,
        canPerform() { return AbilityService.canEditThread(discussion); },
        to() { return `/d/${discussion.key}/edit`; }
      },
        // perform: ->
        //   Records.discussions.remote.fetchById(discussion.key, {exclude_types: 'group user poll event'}).then ->
        //     openModal
        //       component: 'DiscussionForm',
        //       props:
        //         discussion: discussion.clone()

      show_history: {
        icon: 'mdi-history',
        name: 'action_dock.show_edits',
        dock: 1,
        canPerform() { return discussion.edited(); },
        perform() {
          return openModal({
            component: 'RevisionHistoryModal',
            props: {
              model: discussion
            }
          });
        }
      },

      notification_history: {
        name: 'action_dock.notification_history',
        icon: 'mdi-bell-ring-outline',
        menu: true,
        perform() {
          return openModal({
            component: 'AnnouncementHistory',
            props: {
              model: discussion
            }
          });
        },
        canPerform() { return true; }
      },

      export_thread: {
        name: 'common.action.print',
        icon: 'mdi-printer-outline',
        dock: 0,
        menu: true,
        canPerform() {
          return AbilityService.canExportThread(discussion);
        },
        perform() {
          return hardReload(LmoUrlService.discussion(discussion, {export: 1}, {absolute: true, print: true}));
        }
      },

      pin_thread: {
        icon: 'mdi-pin-outline',
        name: 'action_dock.pin_thread',
        menu: true,
        canPerform() { return AbilityService.canPinThread(discussion); },
        perform: () => this.pin(discussion)
      },

      unpin_thread: {
        icon: 'mdi-pin-off',
        name: 'action_dock.unpin_thread',
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
        icon: (discussion.newestFirst && 'mdi-arrow-up') || 'mdi-arrow-down',
        name: (discussion.newestFirst && 'strand_nav.newest_first') || 'strand_nav.oldest_first',
        dock: 3,
        dockLeft: true,
        canPerform() { return AbilityService.canEditThread(discussion); },
        perform() {
          return openModal({
            component: 'ArrangementForm',
            props: {
              discussion: discussion.clone()
            }
          });
        }
      },
            
      close_thread: {
        menu: true,
        icon: 'mdi-archive-outline',
        canPerform() { return AbilityService.canCloseThread(discussion); },
        perform: () => this.close(discussion)
      },

      reopen_thread: {
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
        name: 'action_dock.delete_thread',
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
                  title: 'delete_thread_form.title',
                  helptext: 'delete_thread_form.body',
                  submit: 'delete_thread_form.confirm',
                  flash: 'delete_thread_form.messages.success'
                },
                redirect: LmoUrlService.group(discussion.group())
              }
            }
          });
        }
      }
    };
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
              title: 'close_explanation_modal.close_thread',
              helptext: 'close_explanation_modal.body',
              flash: 'discussion.closed.closed'
            }
          }
        }
      }));
    } else {
      return thread.close().then(() => {
        return Flash.success("discussion.closed.closed", {}, 'undo', () => this.reopen(thread));
      });
    }
  }

  reopen(thread) {
    return thread.reopen().then(() => {
      return Flash.success("discussion.closed.reopened", {}, 'undo', () => this.close(thread));
    });
  }

  dismiss(thread) {
    return thread.dismiss().then(() => {
      return Flash.success("dashboard_page.thread_dismissed", {}, 'undo', () => this.recall(thread));
    });
  }

  recall(thread) {
    return thread.recall().then(() => {
      return Flash.success("dashboard_page.thread_recalled", {}, 'undo', () => this.dismiss(thread));
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
              title: 'pin_thread_modal.title',
              flash: 'discussion.pin.pinned',
              helptext: 'pin_thread_modal.helptext'
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
