<script lang="coffee">
import { settingsFor } from '@/shared/helpers/poll'
import _snakeCase from 'lodash/snakeCase'

export default
  props:
    poll: Object
  data: ->
    settings: settingsFor @poll
  methods:
    snakify: (setting) ->
      _snakeCase setting
  watch:
    'poll.anonymous': (val) ->
      @settings = settingsFor @poll
</script>

<template lang="pug">
v-list.poll-common-settings(two-line)
  v-list-item.poll-common-checkbox-option(v-for="(setting, index) in settings", :key="index")
    v-list-item-action
      v-checkbox(v-model="poll[setting]")
    v-list-item-content
      v-list-item-title(v-t="'poll_common_settings.' + snakify(setting) + '.title'")
      v-list-item-subtitle(v-t="'poll_common_settings.' + snakify(setting) + '.helptext_on'")
</template>
