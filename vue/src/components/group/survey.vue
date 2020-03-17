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
    categories: [
      'business'
      'bcorp'
      'cooperative'
      'consultant'
      'government'
      'nonprofit'
      'union'
      'party'
      'activist'
      'community'
      'education'
      'faith'
      'volunteer'
      'other'
    ]
    sizes: ['ten', 'twenty', 'fifty', 'two_hundred', 'five_hundred', 'two_thousand', 'else']
    uses: ['governance', 'collaboration', 'engagement', 'self_management', 'remote', 'document', 'decision_making', 'funding', 'project', 'forum', 'other']
    referrers: ['google', 'invitation', 'referral', 'social', 'capterra', 'other']
    usage: []
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
            Flash.success('group_survey.success')
            @close()
            @submitting = false
          .catch(onError(@survey, () => @submitting = false))
      else
        Flash.error('group_survey.validation_error')
        @submitting = false

  watch:
    usage: ->
      return unless @usage.length
      @survey.usage = @usage.join(", ")
</script>

<template lang="pug">
v-card.group-survey
  submit-overlay(:value='submitting')
  v-card-title
    v-icon.mr-2(color="primary") mdi-rocket
    h1.headline(v-t="'group_survey.title'")
  v-card-text
    p.body-1.mt-4(v-t="'group_survey.subtitle'")
    v-form(ref="form")
      v-text-field.group-survey__location(v-model='survey.location' :label="$t('group_survey.location')" :rules="[rules.required]")

      v-radio-group.group-survey__category(v-model='survey.category' :label="$t('group_survey.category_question')" :rules="[rules.required]")
        v-radio(v-for='category in categories' :key='category' :value='category' :aria-label='category' :label="$t('group_survey.categories.' + category)" :class="'group-survey__category-' + category")

      v-radio-group.group-survey__size(v-model='survey.size' :label="$t('group_survey.size_question')" :rules="[rules.required]")
        v-radio(v-for='size in sizes' :key='size' :value='size' :aria-label='size' :label="$t('group_survey.sizes.' + size)" :class="'group-survey__size-' + size")

      v-radio-group.group-survey__usage(v-model='usage' :label="$t('group_survey.usage')" :rules="[rules.required]")
        v-radio(v-for='use in uses' :key='use' :value='use' :aria-label='use' :label="$t('group_survey.uses.' + use)" :class="'group-survey__usage-' + use")

      v-radio-group.group-survey__referrer(v-model='survey.referrer' :label="$t('group_survey.referrer')" :rules="[rules.required]")
        v-radio(v-for='referrer in referrers' :key='referrer' :value='referrer' :aria-label='referrer' :label="$t('group_survey.referrers.' + referrer)" :class="'group-survey__referrer-' + referrer")

      v-text-field.group-survey__role(v-model='survey.role' :label="$t('group_survey.role')" :rules="[rules.required]")

      v-text-field.group-survey__website(v-model='survey.website' :label="$t('group_survey.website')" :rules="[rules.required]")

      v-textarea.group-survey__misc(v-model='survey.misc' :label="$t('group_survey.anything_else')")

  v-card-actions
    v-spacer
    v-btn.group-survey__submit-button(:disabled="submitting" color="primary" @click='submit()' v-t="'common.action.save'")
</template>
<style>
.v-text-field__details {
  display: block;
}
</style>
