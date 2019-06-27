<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
import { intersection } from 'lodash'

export default
  props:
    poll: Object
  data: ->
    items: 'agree abstain disagree block'.split(' ')
    colors:
      agree: AppConfig.pollColors.proposal[0]
      abstain: AppConfig.pollColors.proposal[1]
      disagree: AppConfig.pollColors.proposal[2]
      block: AppConfig.pollColors.proposal[3]
</script>

<template lang="pug">
.poll-proposal-form
  poll-common-form-fields(:poll="poll")
  v-combobox(v-model="poll.pollOptionNames" item-avatar="avatar" :items="items" multiple chips deletable-chips :label="$t('poll_common_form.options')")
    template(v-slot:selection="{item, parent, selected}")
      v-chip(pill :color="colors[item]" :key="item")
        v-avatar(:size="30")
          img(:src="'/img/' + item + '.svg'")
        span(v-t="'poll_proposal_options.' + item")
    template(v-slot:item="{index, item}")
      v-list-item-avatar
        img(:src="'/img/'+item+'.svg'")
      v-list-item-content
        v-list-item-title(v-t="'poll_proposal_options.'+item")

  poll-common-closing-at-field(:poll="poll")
  poll-common-settings(:poll="poll")
</template>
