<script lang="js">
import StanceService  from '@/shared/services/stance_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import UrlFor from '@/mixins/url_for';
import { pickBy } from 'lodash-es';

export default {
  mixins: [UrlFor],

  props: {
    topic_item: Object,
    itemable: Object,
    collapsed: Boolean,
    unread: Boolean
  },

  computed: {
    actor() { return this.topic_item.actor(); },
    actorName() { return this.topic_item.actorName(); },
    poll() { return this.itemable.poll(); },
    actions() { return StanceService.actions(this.itemable, this, this.topic_item); },
    dockActions() { return pickBy(this.actions, v => !v.menu); },
    menuActions() { return pickBy(this.actions, v => v.menu); },
    componentType() {
      if (this.actor) {
        return 'router-link';
      } else {
        return 'div';
      }
    },
    link() {
      return LmoUrlService.topic_item(this.topic_item);
    }
  }
};
</script>

<template lang="pug">

section.topic-item__stance-created.stance-created
  template(v-if="itemable.castAt && !itemable.revokedAt")
    template(v-if="itemable.hasOptionIcon()")
      .d-flex.text-body-medium.align-center.pb-1
        component.text-medium-emphasis.text-decoration-none(:is="componentType" :to="actor && urlFor(actor)") {{actorName}}
        space
        poll-common-stance-choice(v-if="poll.showResults()" :poll="poll" :stance-choice="itemable.stanceChoice()")
        space
        router-link.text-medium-emphasis.text-decoration-none(:to='link')
          space
          time-ago(:date='itemable.updatedAt || itemable.castAt')
        v-badge(v-if="unread" variant="tonal" color="info" inline location="right" :content="$t('thread_item.new')")
        template(v-if="!itemable.latest")
          mid-dot.text-medium-emphasis
          v-badge(inline location="right" :content="$t('poll_common.superseded')")
    .poll-common-stance(v-if="poll.showResults() && !collapsed")
      v-layout(v-if="!itemable.hasOptionIcon()" wrap align-center)
        topic-item-headline.text-medium-emphasis(:topic_item="topic_item" :itemable="itemable" :dateTime="itemable.updatedAt || itemable.castAt" :unread="unread")
      poll-common-stance-choices(:stance="itemable")
      .text-medium-emphasis(v-if="itemable.redactedAt" v-t="'poll_common_votes_panel.reason_redacted'")
      template(v-else)
        formatted-text.poll-common-stance-created__reason(:model="itemable" field="reason")
        link-previews(:model="itemable")
        attachment-list(:attachments="itemable.attachments")
    action-dock(:model='itemable' :actions='dockActions' :menu-actions='menuActions' size="small" left)
  template(v-if="!itemable.castAt && !itemable.revokedAt")
    .d-flex
      component.text-medium-emphasis(:is="componentType" :to="actor && urlFor(actor)") {{actorName}}
      mid-dot.text-medium-emphasis
      span(v-t="'poll_common_votes_panel.undecided'")
      mid-dot.text-medium-emphasis
      router-link.text-medium-emphasis(:to='link')
        time-ago(:date='itemable.updatedAt')
    action-dock(:model='itemable', :actions='dockActions' :menu-actions='menuActions' size="small")
  template(v-if="itemable.revokedAt")
    .d-flex
      component.text-medium-emphasis(:is="componentType" :to="actor && urlFor(actor)") {{actorName}}
      mid-dot.text-medium-emphasis
      span.text-medium-emphasis(v-t="'poll_common_votes_panel.vote_removed'")
      mid-dot.text-medium-emphasis
      router-link.text-medium-emphasis(:to='link')
        time-ago(:date='itemable.updatedAt')
    action-dock(:model='itemable' :actions='dockActions' :menu-actions='menuActions' size="small")
</template>
