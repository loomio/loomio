<script lang="coffee">
import { compact, snakeCase, kebabCase } from 'lodash'
import { fieldFromTemplate } from '@/shared/helpers/poll'

export default
  props:
    poll: Object
  data: ->
    currentHideResults: @poll.hideResults
    hideResultsItems: [
      { text: @$t('common.off'), value: 'off' }
      { text: @$t('poll_common_card.until_vote'), value: 'until_vote' }
      { text: @$t('poll_common_card.until_poll_type_closed', pollType: @poll.translatedPollType()), value: 'until_closed' }
    ]

  methods:
    settingDisabled: (setting) ->
      !@poll.closingAt || (!@poll.isNew() && setting == 'anonymous')
    snakify: (setting) -> snakeCase setting
    kebabify: (setting) -> kebabCase setting

  computed:
    allowAnonymous: -> !fieldFromTemplate(@poll.pollType, 'prevent_anonymous')
    settings: ->
      compact [
        ('multipleChoice'         if @poll.pollType == 'poll'),
        ('shuffleOptions'         if ['poll', 'score', 'ranked_choice', 'dot_vote'].includes(@poll.pollType)),
        ('canRespondMaybe'        if @poll.pollType == 'meeting'),
        ('anonymous'              if @allowAnonymous),
        ('voterCanAddOptions'     if fieldFromTemplate(@poll.pollType, 'can_add_options') && @poll.pollType != 'proposal'),
        ('allowLongReason')
      ]
</script>

<template lang="pug">
.poll-common-settings
  v-select.poll-common-settings__hide-results(
    v-if="allowAnonymous"
    :label="$t('poll_common_card.hide_results')"
    :items="hideResultsItems"
    v-model="poll.hideResults"
    :disabled="!poll.closingAt || (!poll.isNew() && currentHideResults == 'until_closed')"
  )
  v-radio-group(v-model="poll.specifiedVotersOnly" :disabled="!poll.closingAt" :label="$t('poll_common_settings.who_can_vote')")
    v-radio(v-if="poll.discussionId && !poll.groupId" :value="false" :label="$t('poll_common_settings.specified_voters_only_false_discussion')")
    v-radio(v-if="poll.groupId" :value="false" :label="$t('poll_common_settings.specified_voters_only_false_group')")
    v-radio.poll-common-settings__specified-voters-only(:value="true" :label="$t('poll_common_settings.specified_voters_only_true')")
  .caption.mt-n4(v-if="poll.specifiedVotersOnly" v-t="$t('poll_common_settings.invite_people_next', {poll_type: poll.translatedPollType()})")
  v-checkbox.poll-common-checkbox-option(v-for="(setting, index) in settings" hide-details :disabled="settingDisabled(setting)" :key="index" v-model="poll[setting]" :class="'poll-settings-' + kebabify(setting)" :label="$t('poll_common_settings.' + snakify(setting) + '.title')")
</template>
