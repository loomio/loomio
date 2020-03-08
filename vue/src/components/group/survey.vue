<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import AbilityService from '@/shared/services/ability_service'
import Records  from '@/shared/services/records'
import Flash   from '@/shared/services/flash'
import { isEmpty, compact } from 'lodash'
import { onError } from '@/shared/helpers/form'
import i18n from '@/i18n.coffee'

export default
  props:
    group: Object
    close: Function
  data: ->
    submitting: false
    survey: null
    categories: ['company', 'cooperative', 'bcorp', 'government', 'nonprofit', 'political', 'society', 'union', 'university', 'activist', 'club', 'collective', 'community', 'faith', 'volunteer', 'other']
    sizes: ['ten', 'twenty', 'fifty', 'two_hundred', 'five_hundred', 'two_thousand', 'else']
    uses: ['governance', 'collaboration', 'engagement', 'self_management', 'remote', 'document', 'decision_making', 'funding', 'project', 'forum', 'other']
    referrers: ['google', 'invitation', 'referral', 'social', 'capterra', 'other']
    rules: {
      required: (input) ->
        if input && input.length
          true
        else
          i18n.t('common.required')
    }
  created: ->
    @survey = Records.groupSurveys.build
                groupId: @group.id

  methods:
    submit: ->
      @submitting = true
      if @$refs.form.validate()
        @survey.save()
          .then (data) =>
            @close()
            @submitting = false
          .catch(onError(@survey, () => @submitting = false))
      else
        @submitting = false
</script>

<template lang="pug">
v-card.group-form
  submit-overlay(:value='submitting')
  v-card-title
    h1.headline(v-t="'group_survey.title'")
    p.body-1.mt-4(v-t="'group_survey.subtitle'")
  v-card-text
    v-form(ref="form")
      v-text-field(v-model='survey.location' :label="$t('group_survey.location')" :rules="[rules.required]")

      v-radio-group(v-model='survey.category' :label="$t('group_survey.category_question')" :rules="[rules.required]")
        v-radio(v-for='category in categories' :key='category' :value='category' :aria-label='category' :label="$t('group_survey.categories.' + category)")

      v-radio-group(v-model='survey.size' :label="$t('group_survey.size_question')" :rules="[rules.required]")
        v-radio(v-for='size in sizes' :key='size' :value='size' :aria-label='size' :label="$t('group_survey.sizes.' + size)")

      v-radio-group(v-model='survey.usage' :label="$t('group_survey.usage')" multiple :rules="[rules.required]")
        v-radio(v-for='use in uses' :key='use' :value='use' :aria-label='use' :label="$t('group_survey.uses.' + use)")

      v-radio-group(v-model='survey.referrer' :label="$t('group_survey.referrer')" :rules="[rules.required]")
        v-radio(v-for='referrer in referrers' :key='referrer' :value='referrer' :aria-label='referrer' :label="$t('group_survey.referrers.' + referrer)")

      v-text-field(v-model='survey.role' :label="$t('group_survey.role')" :rules="[rules.required]")

      v-text-field(v-model='survey.website' :label="$t('group_survey.website')" :rules="[rules.required]")

      v-textarea(v-model='survey.misc' :label="$t('group_survey.anything_else')")

  v-card-actions
    v-spacer
    v-btn.group-form__submit-button(:disabled="submitting" color="primary" @click='submit()' v-t="'common.action.save'")
</template>
<style>
.v-text-field__details {
  display: block;
}
</style>
