<script lang="js">
import StanceService  from '@/shared/services/stance_service';
import LmoUrlService  from '@/shared/services/lmo_url_service';
import UrlFor from '@/mixins/url_for';
import { pickBy } from 'lodash-es';

export default {
  mixins: [UrlFor],

  props: {
    event: Object,
    eventable: Object,
    collapsed: Boolean,
    unread: Boolean
  },

  computed: {
    actor() { return this.event.actor(); },
    actorName() { return this.event.actorName(); },
    poll() { return this.eventable.poll(); },
    actions() { return StanceService.actions(this.eventable, this, this.event); },
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
      return LmoUrlService.event(this.event);
    }
  }
};
</script>

<template lang="pug">

section.strand-item__stance-created.stance-created
  template(v-if="eventable.castAt && !eventable.revokedAt")
    template(v-if="eventable.hasOptionIcon()")
      .d-flex.text-body-medium.align-center.pb-1
        component.text-medium-emphasis.text-decoration-none(:is="componentType" :to="actor && urlFor(actor)") {{actorName}}
        space
        poll-common-stance-choice(v-if="poll.showResults()" :poll="poll" :stance-choice="eventable.stanceChoice()")
        space
        router-link.text-medium-emphasis.text-decoration-none(:to='link')
          space
          time-ago(:date='eventable.updatedAt || eventable.castAt')
        v-badge(v-if="unread" variant="tonal" color="info" inline location="right" :content="$t('thread_item.new')")
        template(v-if="!eventable.latest")
          mid-dot.text-medium-emphasis
          v-badge(inline location="right" :content="$t('poll_common.superseded')")
    .poll-common-stance(v-if="poll.showResults() && !collapsed")
      v-layout(v-if="!eventable.hasOptionIcon()" wrap align-center)
        strand-item-headline.text-medium-emphasis(:event="event" :eventable="eventable" :dateTime="eventable.updatedAt || eventable.castAt" :unread="unread")
      poll-common-stance-choices(:stance="eventable")
      .text-medium-emphasis(v-if="eventable.redactedAt" v-t="'poll_common_votes_panel.reason_redacted'")
      template(v-else)
        formatted-text.poll-common-stance-created__reason(:model="eventable" field="reason")
        link-previews(:model="eventable")
        attachment-list(:attachments="eventable.attachments")
    action-dock(:model='eventable' :actions='dockActions' :menu-actions='menuActions' size="small" left)
  template(v-if="!eventable.castAt && !eventable.revokedAt")
    .d-flex
      component.text-medium-emphasis(:is="componentType" :to="actor && urlFor(actor)") {{actorName}}
      mid-dot.text-medium-emphasis
      span(v-t="'poll_common_votes_panel.undecided'")
      mid-dot.text-medium-emphasis
      router-link.text-medium-emphasis(:to='link')
        time-ago(:date='eventable.updatedAt')
    action-dock(:model='eventable', :actions='dockActions' :menu-actions='menuActions' size="small")
  template(v-if="eventable.revokedAt")
    .d-flex
      component.text-medium-emphasis(:is="componentType" :to="actor && urlFor(actor)") {{actorName}}
      mid-dot.text-medium-emphasis
      span.text-medium-emphasis(v-t="'poll_common_votes_panel.vote_removed'")
      mid-dot.text-medium-emphasis
      router-link.text-medium-emphasis(:to='link')
        time-ago(:date='eventable.updatedAt')
    action-dock(:model='eventable' :actions='dockActions' :menu-actions='menuActions' size="small")
</template>
