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
        'notifyOnParticipate',
        ('canRespondMaybe'       if @poll.pollType == 'meeting'),
        ('anonymous'             if !fieldFromTemplate(@poll.pollType, 'prevent_anonymous')),
        ('hideResultsUntilClosed' if !fieldFromTemplate(@poll.pollType, 'prevent_anonymous')),
        ('voterCanAddOptions'    if fieldFromTemplate(@poll.pollType, 'can_add_options') && @poll.pollType != 'proposal')
      ]
  methods:
    settingDisabled: (setting) -> !@poll.isNew() && ['anonymous', 'hideResultsUntilClosed'].includes(setting)
    snakify: (setting) -> snakeCase setting
    kebabify: (setting) -> kebabCase setting
</script>

<template lang="pug">
.poll-common-settings
  v-checkbox.poll-common-checkbox-option(v-for="(setting, index) in settings" hide-details :disabled="settingDisabled(setting)" :key="index" v-model="poll[setting]" :class="'poll-settings-' + kebabify(setting)" :label="$t('poll_common_settings.' + snakify(setting) + '.title')")
</template>
