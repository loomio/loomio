<script lang="js">
import DiscussionService  from '@/shared/services/discussion_service';
import { pickBy } from 'lodash-es';
import Session from '@/shared/services/session';
import openModal      from '@/shared/helpers/open_modal';
import StrandActionsPanel from '@/components/strand/actions_panel';
import UrlFor from '@/mixins/url_for';

export default {
  mixins: [UrlFor],
  components: {
    StrandActionsPanel
  },
  props: {
    event: Object,
    eventable: Object,
    collapsed: Boolean
  },

  data() {
    return {
      actions: []
    };
  },

  mounted() {
    this.rebuildActions();
  },

  computed: {
    topic() {
      return this.eventable.topic();
    },
    author() {
      return this.discussion.author();
    },

    authorName() {
      return this.discussion.authorName();
    },

    discussion() { return this.eventable; },

    group() {
      return this.discussion.group();
    },

    dockActions() {
      return pickBy(this.actions, v => v.dock);
    },

    menuActions() {
      return pickBy(this.actions, v => v.menu);
    },

    status() {
      if (this.discussion.pinned) { return 'pinned'; }
    },
  },

  methods: {
    rebuildActions() {
      this.actions = DiscussionService.actions(this.eventable, this);
    },

    viewed(viewed) {
      if (viewed && Session.isSignedIn()) {
        this.topic.markAsSeen();
        if (Session.user().autoTranslate && this.actions['translate_thread'].canPerform()) {
          this.actions['translate_thread'].perform().then(() => { this.rebuildActions() });
        }
      }
    },

    openSeenByModal() {
      openModal({
        component: 'SeenByModal',
        persistent: false,
        props: {
          discussion: this.discussion,
        }
      });
    }
  }
};

</script>

<template lang="pug">
.strand-new-discussion.context-panel#context(v-intersect.once="{handler: viewed}")
  strand-header.pt-3(:topicable="discussion")
  .mb-4.text-body-2
    user-avatar.mr-2(:user='author')
    router-link.text-medium-emphasis(:to="urlFor(author)") {{authorName}}
    mid-dot
    router-link.text-medium-emphasis(:to='urlFor(discussion)')
      time-ago(:date='discussion.createdAt')
    span.text-medium-emphasis(v-show='topic.seenByCount > 0')
      mid-dot
      a.context-panel__seen_by_count.underline-on-hover(v-t="{ path: 'discussion_context.seen_by_count', args: { count: topic.seenByCount } }"  @click="openSeenByModal()")

  template(v-if="!collapsed")
    formatted-text.context-panel__description(:model="discussion" field="description")
    link-previews(:model="discussion")
    document-list(:model='discussion')
    attachment-list(:attachments="discussion.attachments")
    action-dock.py-2(:model='discussion' :actions='dockActions' :menu-actions='menuActions' color="primary" variant="tonal")
</template>
<style lang="sass">
abbr[title]
  text-decoration: none
a
  cursor: pointer

.context-panel__heading-pin
  margin-left: 4px

.context-panel__discussion-privacy i
  position: relative
  font-size: 14px
  top: 2px

.context-panel__description
  > p:last-of-type
    margin-bottom: 24px

</style>
