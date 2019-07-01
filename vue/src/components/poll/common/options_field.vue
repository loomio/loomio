<script lang="coffee">
import {keys, intersection, uniq, without, compact, map, every} from 'lodash'
import AppConfig  from '@/shared/services/app_config'
import Vue from 'vue'

export default
  props:
    poll: Object

  methods:
    persistChosenOptions: ->
      unless every(@chosenOptionNames.map (name) => @poll.pollOptionNames.includes(name))
        @poll.pollOptionNames = uniq @chosenOptionNames.concat(@poll.pollOptionNames)

    removeOptionName: (name) ->
      return if @chosenOptionNames.includes(name)
      @poll.pollOptionNames = without(@poll.pollOptionNames, name)

    colorFor: (optionName) ->
      AppConfig.pollColors.poll[@poll.pollOptionNames.indexOf(optionName) % AppConfig.pollColors.poll.length]

  computed:
    chosenOptionNames: ->
      compact map(@poll.stanceData, (value, key) => key if value > 0)

    canRemovePollOptions: ->
      @poll.isNew() || (@poll.isActive() && @poll.stancesCount == 0)

</script>
<template lang="pug">
v-combobox(v-model="poll.pollOptionNames" @change="persistChosenOptions()" multiple chips :label="$t('poll_common_form.options')" :placeholder="$t('poll_common_form.options_placeholder')")
  template(v-slot:selection="data")
    v-chip(:close="!chosenOptionNames.includes(data.item)" :color="colorFor(data.item)" @click.stop="removeOptionName(data.item)") {{data.item}}
</template>
