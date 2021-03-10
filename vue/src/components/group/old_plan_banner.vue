<script lang="coffee">
import { differenceInDays, format, parseISO } from 'date-fns'
import Session         from '@/shared/services/session'
import Records         from '@/shared/services/records'
export default
  props:
    group: Object

  data: ->
    isHidden: Session.user().hasExperienced('old-plan-banner')

  methods:
    hideBanner: ->
      Records.users.saveExperience('old-plan-banner')
      @isHidden = true

  computed:
    isOldPlan: ->
      plans = "pp-basic-monthly pp-pro-monthly ap-active-monthly npap-active-monthly pp-basic-annual pp-pro-annual pp-community-annual ap-active-annual ap-community-annual npap-active-annual small-monthly small-yearly"
      plans.includes(@group.subscription.plan)
</script>
<template lang="pug">
v-alert(outlined color="accent" dense v-if="isOldPlan && !isHidden")
  v-layout(align-center)
    div.pr-1
      span(v-t="'current_plan_button.is_old_plan'")
    v-spacer
    v-btn.mr-2(color="accent" :href="'/upgrade/'+group.id" target="_blank" :title="$t('current_plan_button.tooltip')")
      v-icon mdi-rocket
      span(v-if="isOldPlan" v-t="'current_plan_button.view_plans'")
    v-btn(icon @click="hideBanner" :title="$t('common.action.close')")
      v-icon mdi-close
</template>
