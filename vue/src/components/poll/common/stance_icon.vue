<style lang="scss">
.poll-common-stance-icon {
  display: inline-block;
}

.poll-common-stance-icon__svg {
  margin-right: 4px;
  position: relative;
  bottom: -4px;
}

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
  methods:
    useOptionIcon: ->
      fieldFromTemplate(@stanceChoice.poll().pollType, 'has_option_icons')

</script>

<template>
    <div class="poll-common-stance-icon">
      <img v-if="useOptionIcon()" :src="'/img/' + stanceChoice.pollOption().name + '.svg'" alt="stanceChoice.pollOption().name" class="lmo-box--tiny poll-common-stance-icon__svg">
      <div v-if="!useOptionIcon()" :style="{'border-color': stanceChoice.pollOption().color}" class="poll-common-stance-icon__chip"></div>
    </div>
</template>
