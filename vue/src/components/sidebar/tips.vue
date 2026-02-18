<script lang="js">
import AppConfig      from '@/shared/services/app_config';
import Records      from '@/shared/services/records';
import EventBus       from '@/shared/services/event_bus';
import Session        from '@/shared/services/session';
import GroupService   from '@/shared/services/group_service';
import TipService   from '@/shared/services/tip_service';
import WatchRecords from '@/mixins/watch_records';
import UrlFor from '@/mixins/url_for';
import FormatDate from '@/mixins/format_date';
import { sortBy } from 'lodash-es';
import { addDays } from 'date-fns';

export default {
  mixins: [WatchRecords, UrlFor, FormatDate],
  data() {
    return {
      user: Session.user(),
      group: null,
      tips: [],
      spin: true,
      show: true,
      menuOpen: false
    };
  },

  created() {
    setTimeout(() => { this.spin = false; this.show = false }, 8000)
    if (this.group) {
      Records.remote.fetch({ path: 'polls', params: { group_id: this.group.id } });
    }
    this.watchRecords({
      collections: ['groups', 'polls'],
      query: () => {
        this.group = sortBy(this.user.parentGroups().filter( g => addDays(g.createdAt, 28) > (new Date) && g.creatorId == this.user.id && g.subscription.plan != "demo" ), g => (- g.id))[0]
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

    hide() {
      EventBus.$emit('openModal', {
        component: 'ConfirmModal',
        props: {
          confirm: {
            submit: () => {
              return Records.users.saveExperience('hideOnboarding', true);
            },
            text: {
              title: 'tips.hide.hide_onboarding',
              helptext: 'tips.hide.helptext',
              submit: 'auth_form.continue'
            },
          }
        }
      });
    }
  },
  computed: {
    pctComplete() {
      if (this.tips.length == 0) { return 100 }
      return Math.round((this.tips.filter(t => t.completed()).length / this.tips.length) * 100)
    }
  }
};
</script>

<template lang="pug">
v-tooltip(v-model="show" location="bottom" v-if="pctComplete != 100")
  template(v-slot:activator="{ props }")
    v-btn(v-bind="props" icon)
      v-progress-circular(:model-value="pctComplete" color="info" :indeterminate="spin")
        common-icon(name="mdiStarFace" color="primary")

      v-menu(activator="parent" v-model="menuOpen")
        v-card(v-if="pctComplete == 100" style="max-width: 320px")
          v-card-text
            p(v-t="'tips.youve_completed_all_the_steps'")
          .text-center
            v-btn.text-lowercase(size="small" variant="plain" @click="hide")
              span.text-emphasis-medium(v-t="'tips.hide.title'")

        v-list(v-else nav density="compact" :lines="false")
          v-list-subheader
            span(v-t="'tips.getting_started_checklist'")
          v-list-item(v-for="tip in tips" :title="$t(tip.title)" @click="tip.perform" :key="tip.title" :disabled="tip.disabled()")
            template(v-slot:append)
              common-icon(v-if="tip.completed()" name='mdi-check')
          .text-center
            v-btn.text-lowercase(size="small" variant="plain" @click="hide")
              span.text-emphasis-medium(v-t="'tips.hide.title'")
  span(v-if="!menuOpen" v-t="'tips.get_started_here'")
</template>
