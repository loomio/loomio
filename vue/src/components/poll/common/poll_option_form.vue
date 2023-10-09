<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import { pick } from 'lodash'
import I18n from '@/i18n'

export default
  props:
    pollOption: Object
    poll: Object
    submitFn: Function
    edit: Boolean

  data: ->
    nameRules: [(v) => v.length <= 60 || I18n.t("poll_option_form.option_name_validation")],
    icons: [
      {text: 'Thumbs up', value: 'agree'},
      {text: 'Thumbs down', value: 'disagree'},
      {text: 'Thumbs sideways', value: 'abstain'},
      {text: 'Hand up', value: 'block'}
    ],

  computed:
    hasOptionIcon: -> @poll.config().has_option_icon
    hasOptionPrompt: -> @poll.config().per_option_reason_prompt
    hasOptionMeaning: -> @poll.config().options_have_meaning

  methods:
    submit: ->
      @submitFn(@pollOption)
      EventBus.$emit('closeModal')

</script>
<template lang="pug">
v-card.poll-common-option-form
  v-card-title
    h1.headline(v-if="edit" v-t="$t('poll_option_form.edit_option')")
    h1.headline(v-else v-t="$t('poll_poll_form.add_option_placeholder')")
    v-spacer
    dismiss-modal-button
  v-card-text
    v-text-field.poll-option-form__name(
      autofocus
      :label="$t('poll_option_form.option_name')"
      v-model="pollOption.name"
      :hint="$t('poll_option_form.option_name_hint')"
      counter
      :rules="nameRules"
    )
    v-select(v-if="hasOptionIcon", :label="$t('poll_option_form.icon')" v-model="pollOption.icon", :items="icons")
    v-textarea(
      v-if="hasOptionMeaning"
      :label="$t('poll_option_form.meaning')"
      :hint="$t('poll_option_form.meaning_hint')"
      v-model="pollOption.meaning"
      counter="280")
    v-text-field(
      v-if="hasOptionPrompt"
      :label="$t('poll_option_form.prompt')"
      :hint="$t('poll_option_form.prompt_hint')"
      :placeholder="$t('poll_common.reason_placeholder')"
      v-model="pollOption.prompt")
  v-card-actions
    v-spacer
    v-btn.poll-option-form__done-btn(@click="submit" v-t="'common.action.done'") 
</template>
