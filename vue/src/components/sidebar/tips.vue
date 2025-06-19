<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import EventBus       from '@/shared/services/event_bus';
import Session        from '@/shared/services/session';
import GroupService   from '@/shared/services/group_service';
import TipService   from '@/shared/services/tip_service';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';
import { sortBy } from 'lodash-es';

export default {
  mixins: [WatchRecords, UrlFor, FormatDate],
  data() {
    return {
      user: Session.user(),
      group: null,
      tips: [],
      spin: true,
    };
  },

  created() {
    setTimeout(() => { this.spin = false }, 2000)
    this.watchRecords({
      collections: ['groups'],
      query: () => {
        this.group = sortBy(this.user.parentGroups().filter( g => g.creatorId == this.user.id ), g => (- g.id))[0]
        if (!this.group) { return };
        this.tips = TipService.tips(this.user, this.group, this).filter(t => t.show())
      }
    });
  },

  methods: {
    setProfilePicture() { EventBus.$emit('openModal', {component: 'ChangePictureForm'}); },
    openGroupSettings() {
      GroupService.actions(this.group).edit_group.perform();
      this.$router.push(this.urlFor(this.group));
    },
  },
  computed: {
    pctComplete() {
      if (this.tips.length == 0) { return 0 }
      return Math.round((this.tips.filter(t => t.completed()).length / this.tips.length) * 100)
    }
  }
};
</script>

<template lang="pug">
v-btn(icon v-if="tips.length")
  v-progress-circular(:model-value="pctComplete" color="info" :indeterminate="spin")
    common-icon(name="mdiStarFace" color="primary")

  v-menu(activator="parent")
    v-sheet(v-if="pctComplete == 100")
      p Congratulations! You've completed all the steps.
      p If you have any questions, or need an extension for your trial please contact us.
      v-btn Close

    v-list(nav density="compact" :lines="false")
      v-list-subheader
        span(v-t="'tips.complete_these_steps_to_set_up_your_group'")
      v-list-item(v-for="tip in tips" :title="$t(tip.title)" @click="tip.perform" :key="tip.title" :disabled="tip.disabled()")
        template(v-slot:append)
          common-icon(v-if="tip.completed()" name='mdi-check')

</template>
