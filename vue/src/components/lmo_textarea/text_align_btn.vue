<script lang="coffee">
import { isNodeActive } from '@/shared/tiptap_extentions/utils/node'

export default
  props:
    commands: Object
    editor: Object

  methods:
    isActive: (alignment) ->
      isNodeActive(@editor.state, 'textAlign', alignment)

  computed:
    current: ->
      ['left', 'center', 'right'].find((v) => @isActive(v)) || "left"

    alignments: ->
      [
        { label: 'formatting.left_align', value: 'left', command: @commands.alignment },
        { label: 'formatting.center_align', value: 'center', command: @commands.alignment },
        { label: 'formatting.right_align', value: 'right', command: @commands.alignment },
      ]

</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{ on, attrs }")
    div.rounded-lg
      v-btn.drop-down-button(icon v-on="on")
        v-icon mdi-format-align-{{current}}
        v-icon.menu-down-arrow mdi-menu-down
  v-list(dense)
    v-list-item(v-for="(item, index) in alignments" :key="index" :class="{ 'v-list-item--active': isActive(item.value) }" @click="item.command({ textAlign: item.value })")
      v-list-item-icon
        v-icon {{'mdi-format-align-'+item.value}}
      v-list-item-title(v-t="item.label")
</template>

<style lang="sass">

</style>
