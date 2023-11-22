<script lang="js">
import { differenceInDays, format, parseISO } from 'date-fns';
import Session         from '@/shared/services/session';
import Records         from '@/shared/services/records';
export default
{
  props: {
    group: Object
  },

  data() {
    return {isHidden: Session.user().hasExperienced('old-plan-banner')};
  },

  methods: {
    hideBanner() {
      Records.users.saveExperience('old-plan-banner');
      this.isHidden = true;
    }
  },

  computed: {
    isAdmin() {
      return this.group.adminsInclude(Session.user());
    },

    isOldPlan() {
      const plans = "pp-basic-monthly pp-pro-monthly ap-active-monthly npap-active-monthly pp-basic-annual pp-pro-annual pp-community-annual ap-active-annual ap-community-annual npap-active-annual small-monthly small-yearly";
      return plans.includes(this.group.subscription.plan);
    }
  }
};
</script>
<template>

<v-alert outlined="outlined" color="secondary" dense="dense" v-if="isAdmin && isOldPlan && !isHidden">
  <v-layout align-center="align-center">
    <div class="pr-1"><span v-t="'current_plan_button.is_old_plan'"></span></div>
    <v-spacer></v-spacer>
    <v-btn class="mr-2" color="primary" :href="'/upgrade/'+group.id" target="_blank" :title="$t('current_plan_button.tooltip')">
      <common-icon name="mdi-rocket"></common-icon><span v-if="isOldPlan" v-t="'current_plan_button.view_plans'"></span>
    </v-btn>
    <v-btn icon="icon" @click="hideBanner" :title="$t('common.action.close')">
      <common-icon name="mdi-close"></common-icon>
    </v-btn>
  </v-layout>
</v-alert>
</template>
