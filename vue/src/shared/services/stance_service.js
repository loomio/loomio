import AppConfig        from '@/shared/services/app_config';
import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import Flash         from '@/shared/services/flash';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import RescueUnsavedEditsService from '@/shared/services/rescue_unsaved_edits_service';

export default new class StanceService {
  constructor() {
    this.makeAdmin = {
      name: 'membership_dropdown.make_coordinator',
      canPerform(poll, user) {
        return poll.adminsInclude(Session.user()) && !poll.adminsInclude(user);
      },
      perform(poll, user) {
        return Records.remote.post('stances/make_admin', {participant_id: user.id, poll_id: poll.id, exclude_types: 'discussion'});
      }
    };

    this.removeAdmin = {
      name: 'membership_dropdown.demote_coordinator',
      canPerform(poll, user) {
        return poll.adminsInclude(Session.user()) && poll.adminsInclude(user);
      },
      perform(poll, user) {
        return Records.remote.post('stances/remove_admin', {participant_id: user.id, poll_id: poll.id, exclude_types: 'discussion'});
      }
    };

    this.revoke = {
      name: 'membership_dropdown.remove_from.poll',
      canPerform(poll, user) {
        return poll.adminsInclude(Session.user());
      },
      perform(poll, user) {
        return Records.remote.post('stances/revoke', {participant_id: user.id, poll_id: poll.id})
        .then(() => {
          if (user.id === Session.user().id) {
            EventBus.$emit('deleteMyStance', poll.id); 
          }
          return Flash.success("membership_remove_modal.invitation.flash");
        });
      }
    };
  }
  
  actions(stance, vm, event) {
    return {
      react: {
        dock: 1,
        canPerform() {
          return stance.castAt &&
          !stance.discardedAt &&
          !stance.revokedAt &&
          stance.poll().membersInclude(Session.user()) &&
          ((stance.poll().discussionId === null) || !stance.poll().discussion().closedAt);
        }
      },

      edit_stance: {
        name: (stance.poll().config().has_options && 'poll_common.change_vote') || 'poll_common.change_response',
        icon: 'mdi-pencil',
        dock: 1,
        canPerform: () => this.canUpdateStance(stance),
        perform: () => this.updateStance(stance)
      },

      add_comment: {
        name: 'common.action.reply',
        icon: 'mdi-reply',
        dock: 1,
        canPerform() { 
          return stance.castAt &&
          !stance.discardedAt &&
          !stance.revokedAt &&
          !stance.poll().anonymous &&
          AbilityService.canAddComment(stance.poll().discussion());
        },
        perform() {
          if (event.depth === stance.discussion().maxDepth) {
            return EventBus.$emit('toggle-reply', stance, event.parentId);
          } else {
            return EventBus.$emit('toggle-reply', stance, event.id);
          }
        }
      },

      uncast_stance: {
        name: (stance.poll().config().has_options && 'poll_common.remove_your_vote') || 'poll_common.remove_your_response',
        icon: 'mdi-cancel',
        dock: 1,
        canPerform: () => this.canUpdateStance(stance),
        perform: () => this.uncastStance(stance)
      },

      translate_stance: {
        icon: 'mdi-translate',
        name: 'common.action.translate',
        dock: 2,
        canPerform() {
          return (stance.author() && Session.user()) &&
          (stance.author().locale !== Session.user().locale) &&
          AbilityService.canTranslate(stance);
        },
        perform() {
          return stance.translate(Session.user().locale);
        }
      },

      show_history: {
        name: 'action_dock.edited',
        icon: 'mdi-history',
        dock: 3,
        canPerform() { return stance.edited() && !stance.revokedAt; },
        perform() {
          return openModal({
            component: 'RevisionHistoryModal',
            props: {
              model: stance
            }
          });
        }
      }
    };
  }

  updateStance(stance) {
    return openModal({
      component: 'PollCommonEditVoteModal',
      props: {
        stance: stance.clone()
      }
    });
  }
      
  uncastStance(stance) {
    return openModal({
      component: 'ConfirmModal',
      props: {
        confirm: {
          submit() {
            return Records.remote.patch(`stances/${stance.id}/uncast`);
          },
          text: {
            title: 'poll_remove_vote.title',
            helptext: 'poll_remove_vote.helptext',
            submit: 'poll_remove_vote.confirm',
            flash: 'poll_remove_vote.success'
          }
        }
      }
    });
  }

  canUpdateStance(stance) {
    return stance &&
    stance.latest &&
    !stance.revokedAt &&
    (stance.poll().myStanceId === stance.id) &&
    stance.poll().isVotable() && 
    stance.poll().iHaveVoted();
  }
};
