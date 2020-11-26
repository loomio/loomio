<script lang="coffee">
import { compact, snakeCase, kebabCase } from 'lodash'
import { fieldFromTemplate } from '@/shared/helpers/poll'

export default
  props:
    poll: Object
  data: ->
    settings:
      compact [
        ('multipleChoice'        if @poll.pollType == 'poll'),
        ('canRespondMaybe'       if @poll.pollType == 'meeting'),
        ('anonymous'             if !fieldFromTemplate(@poll.pollType, 'prevent_anonymous')),
        ('hideResultsUntilClosed' if !fieldFromTemplate(@poll.pollType, 'prevent_anonymous')),
        ('voterCanAddOptions'    if fieldFromTemplate(@poll.pollType, 'can_add_options') && @poll.pollType != 'proposal')
      ]
  methods:
    settingDisabled: (setting) ->
      !@poll.closingAt || (!@poll.isNew() && ['anonymous', 'hideResultsUntilClosed'].includes(setting))
    snakify: (setting) -> snakeCase setting
    kebabify: (setting) -> kebabCase setting
</script>

<template lang="pug">
.poll-common-settings
  v-radio-group(v-model="poll.specifiedVotersOnly" :disabled="!poll.closingAt" :label="$t('poll_common_settings.who_can_vote')")
    v-radio(v-if="poll.discussionId && !poll.groupId" :value="false" :label="$t('poll_common_settings.specified_voters_only_false_discussion')")
    v-radio(v-if="poll.groupId" :value="false" :label="$t('poll_common_settings.specified_voters_only_false_group')")
    v-radio.poll-common-settings__specified-voters-only(:value="true" :label="$t('poll_common_settings.specified_voters_only_true')")
  .caption.mt-n4(v-if="poll.specifiedVotersOnly" v-t="$t('poll_common_settings.invite_people_next', {poll_type: poll.translatedPollType()})")
  v-checkbox.poll-common-checkbox-option(v-for="(setting, index) in settings" hide-details :disabled="settingDisabled(setting)" :key="index" v-model="poll[setting]" :class="'poll-settings-' + kebabify(setting)" :label="$t('poll_common_settings.' + snakify(setting) + '.title')")
</template>
