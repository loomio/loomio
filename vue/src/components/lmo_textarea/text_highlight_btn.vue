<script lang="coffee">
import colors from 'vuetify/lib/util/colors'
import {map, compact, pick} from 'lodash'
import { findActiveMarkAttribute } from '@/shared/tiptap_extentions/utils/mark'

ourColors = pick(colors, "red pink purple deepPurple indigo blue lightBlue cyan teal green lightGreen lime yellow amber orange deepOrange brown grey".split(" "))

export default
  props:
    commands: Object
    editor: Object

  data: ->
    back: null
    fore: null
    closable: false
    foreColors: ['#191919', '#ffffff'].concat(compact(map(ourColors, (value, key) => value.base)))
    backColors: ['#000000', '#ffffff'].concat(compact(map(ourColors, (value, key) => value.lighten3)))

  methods:
    onSelectFore: (color) ->
      @closable = true
      @fore = color
      @commands.foreColor({foreColor: color})

    onSelectBack: (color) ->
      @closable = true
      @back = color
      @commands.backColor({backColor: color})

  computed:
    activeBack: ->
      findActiveMarkAttribute(@editor.state, 'backColor')

    activeFore: ->
      findActiveMarkAttribute(@editor.state, 'foreColor')

</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{ on, attrs }")
    div.rounded-lg.color-picker-btn(:style="{'background-color': activeBack}")
      v-btn.drop-down-button(icon v-on="on" v-bind="attrs" :title="$t('formatting.colors')")
        v-icon(:color="activeFore") mdi-palette
        v-icon(:color="activeFore").menu-down-arrow mdi-menu-down
  v-card.color-picker
    .caption(v-t="'formatting.text_color'")
    .swatch(v-for="color in foreColors" :class="{'swatch--white': color == '#ffffff', 'swatch--selected': color == activeFore }" :style="{'background-color': color}" @click="onSelectFore(color)") &nbsp;
    .caption(v-t="'formatting.background_color'")
    .swatch(v-for="color in backColors" :class="{'swatch--white': color == '#ffffff', 'swatch--selected': color == activeBack }" :style="{'background-color': color}" @click="onSelectBack(color)") &nbsp;
    .text-center
      v-btn(x-small outlined @click="commands.formatClear" v-t="'formatting.reset'")
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
