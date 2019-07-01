<script lang="coffee">
import Records  from '@/shared/services/records'
import AppConfig  from '@/shared/services/app_config'
import EventBus from '@/shared/services/event_bus'
import { listenForLoading } from '@/shared/helpers/listen'
import { applySequence }    from '@/shared/helpers/apply'
import { submitPoll } from '@/shared/helpers/form'
import PollModalMixin from '@/mixins/poll_modal'
import {uniq, without, isEqual} from 'lodash'

export default
  mixins: [PollModalMixin]
  props:
    poll: Object
    close: Function

  data: ->
    isDisabled: false
    submit: null
    savedOptionsNames: []

  methods:
    persistSavedOptions: ->
      @poll.pollOptionNames = uniq(@savedOptionNames.concat(@poll.pollOptionNames))

    colorFor: (optionName) ->
      AppConfig.pollColors.poll[@poll.pollOptionNames.indexOf(optionName) % AppConfig.pollColors.poll.length]

    removeOptionName: (name) ->
      @poll.pollOptionNames = without(@poll.pollOptionNames, name)
      @persistSavedOptions()

  computed:
    noNewOptions: ->
      isEqual @savedOptionNames, @poll.pollOptionNames

  created: ->
    @savedOptionNames = @poll.pollOptionNames
    @submit = submitPoll @, @poll,
      submitFn: @poll.addOptions
      prepareFn: =>
        @poll.addOption()
      successCallback: =>
        @close()
      flashSuccess: "poll_common_add_option.form.options_added"
</script>

<template lang="pug">
v-card.poll-common-modal
  .lmo-disabled-form(v-show='isDisabled')
  v-card-title
    h1.headline(v-t="'poll_common_add_option.modal.title'")
    v-spacer
    dismiss-modal-button(:close="close")
  v-card-text
    //- .poll-common-add-option-form
    //-   poll-common-form-options(:poll='poll')
    v-combobox(v-model="poll.pollOptionNames" @change="persistSavedOptions()" multiple chips :label="$t('poll_common_form.options')" :placeholder="$t('poll_common_form.options_placeholder')")
      template(v-slot:selection="data")
        v-chip(:close="!savedOptionNames.includes(data.item)" :color="colorFor(data.item)" @click.stop="removeOptionName(data.item)") {{data.item}}
  v-card-actions
    v-spacer
    v-btn(color="primary" :disabled="noNewOptions" @click='submit()' v-t="'poll_common_add_option.form.add_options'")
</template>
