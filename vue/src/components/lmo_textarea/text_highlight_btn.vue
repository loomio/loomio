<script lang="coffee">
import colors from 'vuetify/lib/util/colors'
import {map, compact, pick} from 'lodash'

ourColors = pick(colors, "red pink purple deepPurple indigo blue lightBlue cyan teal green lightGreen lime yellow amber orange deepOrange brown grey".split(" "))

export default
  props:
    editor: Object

  data: ->
    # activeColor: null
    textColors: ['#fff'].concat(compact(map(ourColors, (value, key) => value.base)))
    highlights: ['#000'].concat(compact(map(ourColors, (value, key) => value.lighten3)))

  computed:
    activeHighlight: ->
      return null unless @editor.isActive('highlight')
      @highlights.find (v) => @editor.isActive('highlight', {color: v})
    activeTextColor: ->
      return null unless @editor.getMarkAttributes('textStyle')
      @editor.getMarkAttributes('textStyle').textColor
</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{ on, attrs }")
    div.rounded-lg.color-picker-btn(:style="{'background-color': activeHighlight}")
      v-btn.drop-down-button(:color="activeTextColor" icon v-on="on" v-bind="attrs" :title="$t('formatting.colors')")
        v-icon mdi-palette
        v-icon.menu-down-arrow mdi-menu-down
  v-card.color-picker.pa-2
    .text-center(v-if="activeHighlight || activeTextColor")
      v-btn(block x-small outlined @click="editor.chain().unsetHighlight().unsetTextColor().focus().run()" v-t="'formatting.reset'")
    .caption(v-t="'formatting.text_color'")
    .swatch.swatch-color(v-for="color in textColors" :class="{'swatch--white': color == '#ffffff', 'swatch--selected': color == activeTextColor }" :style="{'background-color': color}" @click="editor.chain().setTextColor(color).focus().run()") &nbsp;
    .swatch.swatch-reset(@click="editor.chain().focus().unsetTextColor().run()")
      v-icon mdi-cancel
    .caption(v-t="'formatting.background_color'")
    .swatch.swatch-color(v-for="color in highlights" :class="{'swatch--white': color == '#ffffff', 'swatch--selected': color == activeHighlight }" :style="{'background-color': color}" @click="editor.chain().setHighlight({color: color}).focus().run()") &nbsp;
    .swatch.swatch-reset(@click="editor.chain().focus().unsetHighlight().run()")
      v-icon mdi-cancel
</template>

<style lang="sass">

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
