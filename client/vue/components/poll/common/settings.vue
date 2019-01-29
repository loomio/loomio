<script lang="coffee">
{ settingsFor } = require 'shared/helpers/poll'

_snakeCase = require('lodash/snakeCase')

module.exports =
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
v-list.poll-common-settings
  v-list-tile.poll-common-checkbox-option(v-for="(setting, index) in settings", :key="index")
    v-checkbox(v-model="poll[setting]")
      v-layout(slot="label" align-center)
        span.pr-1(v-t="'poll_common_settings.' + snakify(setting) + '.title'")
        help-bubble(:helptext="'poll_common_settings.' + snakify(setting) + '.helptext_on'")
</template>
