<style lang="scss">
.poll-common-stance-icon__chip {
  border-left: 8px solid;
  padding-left: 4px;
  margin-right: 8px;
  display: inline-block;
  position: relative;
  height: 36px;
}
</style>

<script lang="coffee">
import { fieldFromTemplate } from '@/shared/helpers/poll'

export default
  props:
    stanceChoice: Object
    size:
      type: Number
      default: 24
  methods:
    useOptionIcon: ->
      fieldFromTemplate(@stanceChoice.poll().pollType, 'has_option_icons')

</script>

<template lang="pug">
.poll-common-stance-icon
  v-avatar.poll-common-stance-icon__svg(tile :size="size" v-if='useOptionIcon()')
    img(:src="'/img/' + stanceChoice.pollOption().name + '.svg'", alt='stanceChoice.pollOption().name')
  .poll-common-stance-icon__chip(v-if='!useOptionIcon()', :style="{'border-color': stanceChoice.pollOption().color}")
</template>
