import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import Flash         from '@/shared/services/flash';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import StanceService from '@/shared/services/stance_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import i18n          from '@/i18n';
import { hardReload } from '@/shared/helpers/window';
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service';
import { startOfHour, addDays, format } from 'date-fns';

function openSetOutcomeModal(poll) {
  Records.pollTemplates.findOrFetchByKeyOrId(poll.pollTemplateKeyOrId()).then(template => {
    const pollTemplate = template || {
      outcomeStatement: null,
      outcomeStatementFormat: Session.defaultFormat(),
      outcomeReviewDueInDays: null,
    };
    let reviewOn = null
    if (pollTemplate.outcomeReviewDueInDays) {
      reviewOn = format(startOfHour(addDays(new Date(), pollTemplate.outcomeReviewDueInDays)), 'yyyy-MM-dd')
    }
    openModal({
      component: 'PollCommonOutcomeModal',
      props: {
        outcome: Records.outcomes.build({
          groupId: poll.groupId,
          pollId: poll.id,
          statement: pollTemplate.outcomeStatement,
          statementFormat: pollTemplate.outcomeStatementFormat,
          reviewOn: reviewOn,
        })
      }
    });
  });
}

export default new class PollService {

  openSetOutcomeModal(poll) { openSetOutcomeModal(poll) }

  actions(poll, vm, event) {
    if (!poll || !poll.config()) { return {}; }
    return {
      translate_poll: {
        icon: 'mdi-translate',
        name: 'common.action.translate',
        dock: 2,
        canPerform() { return AbilityService.canTranslate(poll); },
        perform() { return Session.user() && poll.translate(Session.user().locale); }
      },

      edit_stance: {
        name: (poll.config().has_options && 'poll_common.change_vote') || 'poll_common.change_response',
        icon: 'mdi-pencil',
        dock: 2,
        canPerform() { return StanceService.canUpdateStance(poll.myStance()); },
        perform() { return StanceService.updateStance(poll.myStance()); }
      },

      uncast_stance: {
        name: (poll.config().has_options && 'poll_common.remove_your_vote') || 'poll_common.remove_your_response', 
        icon: 'mdi-cancel',
        menu: true,
        canPerform() { return StanceService.canUpdateStance(poll.myStance()); },
        perform: () => StanceService.uncastStance(poll.myStance())
      },

      edit_poll: {
        name: 'action_dock.edit_poll_type',
        menu: true,
        nameArgs() { return {pollType: poll.translatedPollType()}; },
        icon: 'mdi-pencil',
        canPerform() { return AbilityService.canEditPoll(poll); },
        to() { return `/p/${poll.key}/edit`; }
      },

      make_a_copy: {
        icon: 'mdi-content-copy',
        name: 'templates.make_a_copy',
        menu: true,
        canPerform() { return Session.user(); },
        to() { return `/p/new?template_id=${poll.id}`; }
      },

      add_poll_to_thread: {
        menu: true,
        name: 'action_dock.add_poll_to_thread',
        icon: 'mdi-comment-plus-outline',
        canPerform() { return AbilityService.canAddPollToThread(poll); },
        perform() {
          return openModal({
            component: 'AddPollToThreadModal',
            props: {
              poll
            }
          });
        }
      },

      announce_poll: {
        icon: 'mdi-send',
        name: 'common.action.invite',
        dock: 2,
        canPerform() {
          if (poll.discardedAt || poll.closedAt) { return false; }
          return AbilityService.canAnnouncePoll(poll);
        },
        perform() {
          return openModal({
            component: 'PollMembers',
            props: {
              poll
            }
          });
        }
      },

      remind_poll: {
        icon: 'mdi-send',
        name: 'common.action.remind',
        dock: 2,
        canPerform() {
          if (poll.discardedAt || poll.closedAt || (poll.votersCount < 2)) { return false; }
          return AbilityService.canAnnouncePoll(poll);
        },
        perform() {
          return openModal({
            component: 'PollReminderForm',
            props: {
              poll: poll.clone()
            }
          });
        }
      },

      close_poll: {
        icon: 'mdi-close-circle-outline',
        name: 'poll_common.close_early',
        dock: 2,
        canPerform() {
          return AbilityService.canClosePoll(poll);
        },
        perform() {

          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit() { return poll.close(); },
                successCallback() {
                  openSetOutcomeModal(poll);
                },
                text: {
                  title: 'poll_common_close_form.title',
                  helptext: 'poll_common_close_form.helptext',
                  flash: 'poll_common_close_form.poll_type_closed'
                },
                textArgs: {
                  poll_type: poll.translatedPollType()
                }
              }
            }
          });
        }
      },

      reopen_poll: {
        icon: 'mdi-refresh',
        name: 'common.action.reopen',
        dock: 3,
        canPerform() {
          return AbilityService.canReopenPoll(poll);
        },
        perform() {
          return openModal({
            component: 'PollCommonReopenModal',
            props: { poll }});
        }
      },

      add_comment: {
        name: 'activity_card.add_comment',
        icon: 'mdi-reply',
        dock: 1,
        canPerform() { return !poll.discardedAt && poll.discussionId && AbilityService.canAddComment(poll.discussion()) && !poll.closingAt; },
        perform() {
          return EventBus.$emit('toggle-reply', poll, event.id);
        }
      },

      show_history: {
        icon: 'mdi-history',
        name: 'action_dock.show_edits',
        menu: true,
        canPerform() { return !poll.discardedAt && poll.edited(); },
        perform() {
          return openModal({
            component: 'RevisionHistoryModal',
            props: {
              model: poll
            }
          });
        }
      },

      notification_history: {
        name: 'action_dock.notification_history',
        icon: 'mdi-alarm-check',
        menu: true,
        perform() {
          return openModal({
            component: 'AnnouncementHistory',
            props: {
              model: poll
            }
          });
        },
        canPerform() { return !poll.discardedAt; }
      },

      move_poll: {
        name: 'action_dock.move_thread', // the text is 'move to group'
        icon: 'mdi-folder-swap-outline',
        menu: true,
        canPerform() {
          return AbilityService.canMovePoll(poll);
        },
        perform() {
          return openModal({
            component: 'PollCommonMoveForm',
            props: {
              poll: poll.clone()
            }
          });
        }
      },

      export_poll: {
        name: 'common.action.export',
        icon: 'mdi-database-arrow-right-outline',
        menu: true,
        canPerform() {
          return AbilityService.canExportPoll(poll);
        },
        perform() {
          return hardReload(LmoUrlService.poll(poll, {export: 1}, {action: 'export', ext: 'csv', absolute: true}));
        }
      },

      print_poll: {
        name: 'common.action.print',
        icon: 'mdi-printer-outline',
        menu: true,
        canPerform() {
          return AbilityService.canExportPoll(poll);
        },
        perform() {
          return hardReload(LmoUrlService.poll(poll, {export: 1}, {action: 'export', ext: 'html', absolute: true}));
        }
      },

      // delete_poll:
      //   name: 'common.action.delete'
      //   canPerform: ->
      //     AbilityService.canDeletePoll(poll)
      //   perform: ->
      //     openModal
      //       component: 'ConfirmModal'
      //       props:
      //         confirm:
      //           submit: -> poll.destroy()
      //           text:
      //             title: 'poll_common_delete_modal.title'
      //             confirm: 'poll_common_delete_modal.question'
      //             flash: 'poll_common_delete_modal.success'

      discard_poll: {
        name: 'poll_common.delete_poll',
        menu: true,
        icon: 'mdi-delete',
        canPerform() {
          return AbilityService.canDeletePoll(poll);
        },
        perform() {
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit() { return poll.discard(); },
                text: {
                  raw_title: i18n.t('poll_common_delete_modal.title', {pollType: i18n.t(poll.pollTypeKey())}),
                  helptext: 'poll_common_delete_modal.question',
                  flash: 'poll_common_delete_modal.success'
                }
              }
            }
          });
        }
      }
    };
  }
};

