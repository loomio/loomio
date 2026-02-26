import Session       from '@/shared/services/session';
import Records       from '@/shared/services/records';
import AbilityService from '@/shared/services/ability_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import openModal      from '@/shared/helpers/open_modal';
import { hardReload } from '@/shared/helpers/window';

export default new class DiscussionService {
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
        dock: 3,
        canPerform() { return AbilityService.canTranslate(discussion); },
        perform() { return Records.translations.addTo(discussion, Session.user().locale) }
      },

      untranslate_thread: {
        icon: 'mdi-translate',
        name: 'common.action.original',
        dock: 3,
        canPerform() { return AbilityService.canUntranslate(discussion); },
        perform() { discussion.translationId = null }
      },

      react: {
        dock: 1,
        canPerform() { return AbilityService.canAddComment(discussion); }
      },

      add_comment: {
        icon: 'mdi-reply',
        dockDisplay: 'icon',
        dock: 1,
        canPerform() {
          return AbilityService.canAddComment(discussion) &&
                 !(discussion.group().adminsInclude(Session.user()) ||
                  ((discussion.group().membersCanAnnounce || discussion.group().membersCanAddGuests) && discussion.membersInclude(Session.user())))
        },
        perform() {
          document.querySelector('#add-comment').scrollIntoView();
          document.querySelector('#add-comment').focus();
        }
      },

      edit_thread: {
        name: 'common.action.edit',
        icon: 'mdi-pencil',
        dock: 1,
        canPerform() { return AbilityService.canEditThread(discussion); },
        to() { return `/d/${discussion.key}/edit`; }
      },

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
            persistent: false,
            props: {
              model: discussion,
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
      }
    };
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
};
