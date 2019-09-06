<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { intersection } from 'lodash'
import { optionColors, optionImages } from '@/shared/helpers/poll'

export default
  props:
    poll: Object
  data: ->
    items: [
      {text: @$t('poll_proposal_options.agree_abstain_disagree_block'), value: ['agree', 'abstain', 'disagree', 'block']}
      {text: @$t('poll_proposal_options.agree_abstain_disagree'), value: ['agree', 'abstain', 'disagree']}
      {text: @$t('poll_proposal_options.consent_abstain_object'), value: ['consent', 'abstain', 'objection']}
      {text: @$t('poll_proposal_options.no_voting'), value: []}
    ]
    optionColors: optionColors()
    optionImages: optionImages()
</script>

<template lang="pug">
.poll-proposal-form
  poll-common-form-fields(:poll="poll")
  v-select(:disabled="!poll.isNew()" v-model="poll.pollOptionNames" :items="items" :label="$t('poll_common_form.options')")
  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
