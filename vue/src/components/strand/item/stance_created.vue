<script lang="js">
import Session        from '@/shared/services/session';
import StanceService        from '@/shared/services/stance_service';
import AbilityService from '@/shared/services/ability_service';
import openModal from '@/shared/helpers/open_modal';
import LmoUrlService  from '@/shared/services/lmo_url_service';

export default {
  props: {
    event: Object,
    eventable: Object,
    collapsed: Boolean
  },

  computed: {
    actor() { return this.event.actor(); },
    actorName() { return this.event.actorName(); },
    poll() { return this.eventable.poll(); },
    actions() { return StanceService.actions(this.eventable, this, this.event); },
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

section.strand-item__stance-created.stance-created(id="'comment-'+ eventable.id", :event="event")
  template(v-if="eventable.castAt && !eventable.revokedAt")
    template(v-if="eventable.hasOptionIcon()")
      .d-flex
        component.text--secondary(:is="componentType", :to="actor && urlFor(actor)") {{actorName}}
        space
        space
        poll-common-stance-choice(v-if="poll.showResults()", :poll="poll", :stance-choice="eventable.stanceChoice()")
        space
        router-link.text--secondary(:to='link')
          space
          time-ago(:date='eventable.updatedAt || eventable.castAt')
        template(v-if="!eventable.latest")
          mid-dot.text--secondary
          span.text--secondary(v-t="'poll_common.superseded'")
    .poll-common-stance(v-if="poll.showResults() && !collapsed")
      v-layout(v-if="!eventable.hasOptionIcon()" wrap align-center)
        strand-item-headline.text--secondary(:event="event" :eventable="eventable" :dateTime="eventable.updatedAt || eventable.castAt")
      poll-common-stance-choices(:stance="eventable")
      formatted-text.poll-common-stance-created__reason(:model="eventable", column="reason")
      link-previews(:model="eventable")
      attachment-list(:attachments="eventable.attachments")
    action-dock(:model='eventable', :actions='actions' small left)
  template(v-if="!eventable.castAt && !eventable.revokedAt")
    .d-flex
      component.text--secondary(:is="componentType", :to="actor && urlFor(actor)") {{actorName}}
      mid-dot.text--secondary
      span(v-t="'poll_common_votes_panel.undecided'")
      mid-dot.text--secondary
      router-link.text--secondary(:to='link')
        time-ago(:date='eventable.updatedAt')
    action-dock(:model='eventable', :actions='actions' small)
  template(v-if="eventable.revokedAt")
    .d-flex
      component.text--secondary(:is="componentType", :to="actor && urlFor(actor)") {{actorName}}
      mid-dot.text--secondary
      span.text--secondary(v-t="'poll_common_votes_panel.vote_removed'")
      mid-dot.text--secondary
      router-link.text--secondary(:to='link')
        time-ago(:date='eventable.updatedAt')
    action-dock(:model='eventable', :actions='actions' small)
</template>
