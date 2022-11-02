<script lang="coffee">
import Records from '@/shared/services/records'
import EventBus from '@/shared/services/event_bus'
import { pick } from 'lodash'

export default
  props:
    pollOption: Object
    poll: Object

  data: ->
    clone: pick(@pollOption, 'name', 'icon', 'meaning', 'prompt')
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
      Object.assign(@pollOption, @clone)
      EventBus.$emit('closeModal')

</script>
<template lang="pug">
v-card.poll-common-option-form
  v-card-title
    h1.headline(v-t="$t('poll_option_form.edit_option')")
    v-spacer
    dismiss-modal-button
  v-card-text
    v-text-field(
      :label="$t('poll_option_form.option_name')"
      v-model="clone.name"
      :hint="$t('poll_option_form.option_name_hint')"
      :rules="nameRules"
      counter="85"
    )
    v-select(v-if="hasOptionIcon", :label="$t('poll_option_form.icon')" v-model="clone.icon", :items="icons")
    v-textarea(
      v-if="hasOptionMeaning"
      :label="$t('poll_option_form.meaning')"
      :hint="$t('poll_option_form.meaning_hint')"
      v-model="clone.meaning")
    v-text-field(
      v-if="hasOptionPrompt"
      :label="$t('poll_option_form.prompt')"
      :hint="$t('poll_option_form.prompt_hint')"
      :placeholder="$t('poll_common.reason_placeholder')"
      v-model="clone.prompt")
  v-card-actions
    v-spacer
    v-btn(@click="submit" v-t="'common.action.done'") 
</template>
