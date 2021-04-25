<script lang="coffee">
import colors from 'vuetify/lib/util/colors'
import {map, compact, pick} from 'lodash'

ourColors = pick(colors, "red pink purple deepPurple indigo blue lightBlue cyan teal green lightGreen lime yellow amber orange deepOrange brown grey".split(" "))

export default
  props:
    editor: Object

  data: ->
    # activeColor: null
    backgrounds: ['#000000', '#ffffff'].concat(compact(map(ourColors, (value, key) => value.lighten3)))

  computed:
    activeBackground: ->
      return null unless @editor.isActive('highlight')
      @backgrounds.find (v) => @editor.isActive('highlight', {color: v})
</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{ on, attrs }")
    div.rounded-lg.color-picker-btn(:style="{'background-color': activeBackground}")
      v-btn.drop-down-button(icon v-on="on" v-bind="attrs" :title="$t('formatting.colors')")
        v-icon mdi-palette
        v-icon.menu-down-arrow mdi-menu-down
  v-card.color-picker
    .caption(v-t="'formatting.background_color'")
    .swatch(v-for="color in backgrounds" :class="{'swatch--white': color == '#ffffff', 'swatch--selected': color == activeBackground }" :style="{'background-color': color}" @click="editor.chain().focus().setHighlight({color: color}).run()") &nbsp;
    .text-center
      v-btn(x-small outlined @click="editor.chain().focus().unsetHighlight().run()" v-t="'formatting.reset'")
</template>

<style lang="sass">

.color-picker
  width: 240px

.swatch
  display: inline-block
  width: 24px
  height: 24px
  border-radius: 24px
  border: 1px solid white

.swatch--white
  border: 1px solid #ddd

.swatch--selected
  border: 1px dotted #000

.swatch:hover
  border: 1px solid grey

.swatch-active
  border: 1px solid black
</style>
