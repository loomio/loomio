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

<template>

<section class="strand-item__stance-created stance-created" id="'comment-'+ eventable.id" :event="event">
  <template v-if="eventable.castAt && !eventable.revokedAt">
    <template v-if="eventable.hasOptionIcon()">
      <div class="d-flex">
        <component class="text--secondary" :is="componentType" :to="actor && urlFor(actor)">{{actorName}}</component>
        <space></space>
        <space></space>
        <poll-common-stance-choice v-if="poll.showResults()" :poll="poll" :stance-choice="eventable.stanceChoice()"></poll-common-stance-choice>
        <space></space>
        <router-link class="text--secondary" :to="link">
          <space></space>
          <time-ago :date="eventable.updatedAt || eventable.castAt"></time-ago>
        </router-link>
        <template v-if="!eventable.latest">
          <mid-dot class="text--secondary"></mid-dot><span class="text--secondary" v-t="'poll_common.outdated'"></span>
        </template>
      </div>
    </template>
    <div class="poll-common-stance" v-if="poll.showResults() && !collapsed">
      <v-layout v-if="!eventable.hasOptionIcon()" wrap="wrap" align-center="align-center">
        <strand-item-headline class="text--secondary" :event="event" :eventable="eventable" :dateTime="eventable.updatedAt || eventable.castAt"></strand-item-headline>
      </v-layout>
      <poll-common-stance-choices :stance="eventable"></poll-common-stance-choices>
      <formatted-text class="poll-common-stance-created__reason" :model="eventable" column="reason"></formatted-text>
      <link-previews :model="eventable"></link-previews>
      <attachment-list :attachments="eventable.attachments"></attachment-list>
    </div>
    <action-dock :model="eventable" :actions="actions" small="small" left="left"></action-dock>
  </template>
  <template v-if="!eventable.castAt && !eventable.revokedAt">
    <div class="d-flex">
      <component class="text--secondary" :is="componentType" :to="actor && urlFor(actor)">{{actorName}}</component>
      <mid-dot class="text--secondary"></mid-dot><span v-t="'poll_common_votes_panel.undecided'"></span>
      <mid-dot class="text--secondary"></mid-dot>
      <router-link class="text--secondary" :to="link">
        <time-ago :date="eventable.updatedAt"></time-ago>
      </router-link>
    </div>
    <action-dock :model="eventable" :actions="actions" small="small"></action-dock>
  </template>
  <template v-if="eventable.revokedAt">
    <div class="d-flex">
      <component class="text--secondary" :is="componentType" :to="actor && urlFor(actor)">{{actorName}}</component>
      <mid-dot class="text--secondary"></mid-dot><span class="text--secondary" v-t="'poll_common_votes_panel.vote_removed'"></span>
      <mid-dot class="text--secondary"></mid-dot>
      <router-link class="text--secondary" :to="link">
        <time-ago :date="eventable.updatedAt"></time-ago>
      </router-link>
    </div>
    <action-dock :model="eventable" :actions="actions" small="small"></action-dock>
  </template>
</section>
</template>
