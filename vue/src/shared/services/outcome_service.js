/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let OutcomeService;
import openModal from '@/shared/helpers/open_modal';
import AbilityService from '@/shared/services/ability_service';
import Records from '@/shared/services/records';
import Session from '@/shared/services/session';

export default new (OutcomeService = class OutcomeService {
  actions(outcome) {
    const poll = outcome.poll();
    const user = Session.user();

    return {
      translate_outcome: {
        name: 'common.action.translate',
        icon: 'mdi-translate',
        dock: 2,
        canPerform() {
          return AbilityService.canTranslate(outcome);
        },
        perform() {
          return Session.user() && outcome.translate(user.locale);
        }
      },

      react: {
        dock: 1,
        canPerform() { return poll.membersInclude(user); }
      },

      edit_outcome: {
        name: 'common.action.edit',
        icon: 'mdi-pencil',
        dock: 1,
        canPerform() { return AbilityService.canSetPollOutcome(poll); },
        perform() {
          return openModal({
            component: 'PollCommonOutcomeModal',
            props: {
              outcome: outcome.clone()
            }
          });
        }
      },

      show_history: {
        icon: 'mdi-history',
        name: 'action_dock.show_edits',
        dock: 1,
        canPerform() { return outcome.edited(); },
        perform() {
          return openModal({
            component: 'RevisionHistoryModal',
            props: {
              model: outcome
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
              model: outcome
            }
          });
        },
        canPerform() { return true; }
      }
    };
  }
});
