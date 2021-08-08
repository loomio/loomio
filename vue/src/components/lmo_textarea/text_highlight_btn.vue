<script lang="coffee">
import colors from 'vuetify/lib/util/colors'
import {map, compact, pick} from 'lodash'

ourColors = pick(colors, "red pink purple deepPurple indigo blue lightBlue cyan teal green lightGreen lime yellow amber orange deepOrange brown grey".split(" "))

export default
  props:
    editor: Object

  data: ->
    highlights: compact(map(ourColors, (value, key) => value.lighten3))

  computed:
    activeHighlight: ->
      return null unless @editor.isActive('highlight')
      @highlights.find (v) => @editor.isActive('highlight', {color: v})
</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{ on, attrs }")
    div.rounded-lg.color-picker-btn
      v-btn.drop-down-button(:style="{'background-color': activeHighlight}" icon v-on="on" v-bind="attrs" :title="$t('formatting.colors')")
        v-icon mdi-palette
        v-icon.menu-down-arrow mdi-menu-down
  v-card.color-picker.pa-2
    .caption(v-t="'formatting.background_color'")
    .swatch.swatch-color(v-for="color in highlights" :class="{'swatch--white': color == '#ffffff', 'swatch--selected': color == activeHighlight }" :style="{'background-color': color}" @click="editor.chain().setHighlight({color: color}).focus().run()") &nbsp;
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
