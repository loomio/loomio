<script lang="coffee">
import AppConfig from '@/shared/services/app_config'
export default
  props:
    poll: Object

  data: ->
    items: 'yes no'.split(' ')
    colors:
      yes: AppConfig.pollColors.count[0]
      no: AppConfig.pollColors.count[1]

</script>
<template lang="pug">
.poll-count-form
  poll-common-form-fields(:poll="poll")
  poll-common-closing-at-field(:poll="poll")
  v-select(v-model="poll.pollOptionNames" item-avatar="avatar" :items="items" multiple chips deletable-chips :label="$t('poll_common_form.options')")
    template(v-slot:selection="{item, parent, selected}")
      v-chip(pill :key="item")
        v-avatar(:size="30")
          img(:src="'/img/' + item + '.svg'")
        span(v-t="'poll_count_options.' + item")
    template(v-slot:item="{index, item}")
      v-list-item-avatar
        img(:src="'/img/'+item+'.svg'")
      v-list-item-content
        v-list-item-title(v-t="'poll_count_options.'+item")

  poll-common-settings(:poll="poll")
</template>
