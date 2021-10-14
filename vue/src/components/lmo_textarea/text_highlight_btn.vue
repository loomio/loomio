<script lang="coffee">
import colors from 'vuetify/lib/util/colors'
import {map, compact, pick, keys} from 'lodash'

export default
  props:
    editor: Object

  data: ->
    colors: pick(colors, "red pink purple blue green yellow orange brown grey".split(" "))

  computed:
    activeColorKey: ->
      return null unless @editor.isActive('highlight')
      keys(@colors).find (name) => @editor.isActive('highlight', {color: name})

    buttonBgColor: ->
      (@colors[@activeColorKey] || {lighten1: null}).lighten2
    buttonFgColor: ->
      if @buttonBgColor
        '#000'
      else
        undefined
</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{ on, attrs }")
    div.rounded-lg.color-picker-btn
      //- v-btn.drop-down-button(icon v-on="on" v-bind="attrs" :title="$t('formatting.colors')")
      v-btn.drop-down-button(:style="{'background-color': buttonBgColor, color: buttonFgColor}" icon v-on="on" v-bind="attrs" :title="$t('formatting.colors')")
        v-icon mdi-palette
        v-icon.menu-down-arrow mdi-menu-down
  v-card.color-picker.pa-2
    .swatch.swatch-color(v-for="(value, key) in colors"
                         :class="{'swatch--selected': key == activeColorKey }"
                         :style="{'background-color': value.lighten1}"
                         @click="editor.chain().setHighlight({color: key}).focus().run()") &nbsp;
    v-btn.mt-2(block x-small outlined @click="editor.chain().unsetHighlight().focus().run()" v-t="'formatting.reset'")
</template>

<style lang="sass">

.color-picker-btn
  padding-left: 1px

.color-picker
  width: 280px

.swatch
  box-sizing: border-box
  display: inline-block
  width: 24px
  height: 24px
  margin: 1px
  border: 1px solid transparent
  border-radius: 2px
  transition: border-radius 0.1s linear

.swatch--color
  // border-radius: 24px
  border: 2px solid transparent

.swatch--white
  border: 2px solid #ddd

.swatch--selected
  border-radius: 24px

.swatch:hover
  cursor: pointer
  border-radius: 8px

.swatch-active
  border-radius: 24px
</style>
