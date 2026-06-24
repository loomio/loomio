import AppConfig        from '@/shared/services/app_config';
import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import Flash         from '@/shared/services/flash';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import BookmarkService from '@/shared/services/bookmark_service';

export default new class StanceService {
  revoke = {
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

  actions(stance, vm, event) {
    return {
      save_bookmark: {
        icon: 'mdi-bookmark-outline',
        name: 'action_dock.save_bookmark',
        menu: true,
        canPerform() {
          const poll = stance.poll();
          return poll && poll.showResults() && Session.isSignedIn() && !BookmarkService.bookmarkFor(stance);
        },
        perform() { return BookmarkService.actions(stance).save_bookmark.perform(); }
      },

      remove_bookmark: {
        icon: 'mdi-bookmark',
        name: 'action_dock.remove_bookmark',
        menu: true,
        canPerform() { return Session.isSignedIn() && !!BookmarkService.bookmarkFor(stance); },
        perform() { return BookmarkService.actions(stance).remove_bookmark.perform(); }
      },

      react: {
        dock: 1,
        canPerform() {
          const poll = stance.poll();
          const topic = poll ? poll.topic() : null;
          return stance.castAt &&
          !stance.discardedAt &&
          !stance.revokedAt &&
          poll && poll.showResults() &&
          poll.membersInclude(Session.user()) &&
          (!topic || (!topic.lockedAt && topic.allowReactions));
        }
      },

      add_comment: {
        name: 'common.action.reply',
        icon: 'mdi-reply',
        dock: 3,
        canPerform() {
          const poll = stance.poll();
          const topic = poll ? poll.topic() : null;
          return stance.castAt &&
          !stance.discardedAt &&
          !stance.revokedAt &&
          poll && !poll.anonymous &&
          poll.showResults() &&
          topic && topic.membersInclude(Session.user()) &&
          !topic.lockedAt;
        },
        perform() {
          const topic = stance.poll() ? stance.poll().topic() : null;
          const maxDepth = topic ? topic.maxDepth : 2;
          if (event.depth === maxDepth) {
            return EventBus.$emit('toggle-reply', stance, event.parentId);
          } else {
            return EventBus.$emit('toggle-reply', stance, event.id);
          }
        }
      },

      edit_stance: {
        name: (stance.poll().config().has_options && 'poll_common.change_vote') || 'poll_common.change_response',
        icon: 'mdi-pencil',
        dock: 3,
        canPerform: () => !!this.canUpdateStance(stance),
        perform: () => this.updateStance(stance)
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
      },

      redact_stance: {
        name: 'common.action.redact',
        icon: 'mdi-eye-off',
        menu: true,
        canPerform() { return AbilityService.canRedactStance(stance); },
        perform() {
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit() {
                  return Records.stances.remote.patchMember(stance.id, 'redact');
                },
                text: {
                  title: 'poll_common_votes_panel.redact_reason_title',
                  helptext: 'poll_common_votes_panel.redact_reason_helptext',
                  submit: 'poll_common_votes_panel.redact_reason_confirm',
                  flash: 'poll_common_votes_panel.redact_reason_success'
                }
              }
            }
          });
        }
      },

      unredact_stance: {
        name: 'common.action.unredact',
        icon: 'mdi-eye',
        menu: true,
        canPerform() { return AbilityService.canUnredactStance(stance); },
        perform() {
          return openModal({
            component: 'ConfirmModal',
            props: {
              confirm: {
                submit() {
                  return Records.stances.remote.patchMember(stance.id, 'unredact');
                },
                text: {
                  title: 'poll_common_votes_panel.unredact_reason_title',
                  helptext: 'poll_common_votes_panel.unredact_reason_helptext',
                  submit: 'poll_common_votes_panel.unredact_reason_confirm',
                  flash: 'poll_common_votes_panel.unredact_reason_success'
                }
              }
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
