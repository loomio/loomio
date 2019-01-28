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
.poll-common-settings
  .md-block.poll-common-multiple-choice.poll-common-checkbox-option(v-for="(setting, index) in settings", :key="index")
    .poll-common-checkbox-option__text.md-list-item-text.lmo-flex--row
      h3(v-t="'poll_common_settings.' + snakify(setting) + '.title'")
    help-bubble(:helptext="'poll_common_settings.' + snakify(setting) + '.helptext_on'")
    v-checkbox(v-model="poll[setting]")
</template>
