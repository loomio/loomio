<script lang="coffee">
import { isNodeActive } from '@/shared/tiptap_extentions/utils/node'

export default
  props:
    editor: Object

  methods:
    isActive: (alignment) ->
      @editor.isActive({ textAlign: alignment })

  computed:
    current: ->
      ['left', 'center', 'right'].find((v) => @isActive(v)) || "left"

    alignments: ->
      [
        { label: 'formatting.left_align', value: 'left' },
        { label: 'formatting.center_align', value: 'center' },
        { label: 'formatting.right_align', value: 'right' },
      ]

</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{ on, attrs }")
    div.rounded-lg
      v-btn.drop-down-button(icon v-on="on" :title="$t('formatting.alignment')")
        v-icon mdi-format-align-{{current}}
        v-icon.menu-down-arrow mdi-menu-down
  v-list(dense)
    v-list-item(v-for="(item, index) in alignments" :key="index" :class="{ 'v-list-item--active': editor.isActive({ textAlign: item.value }) }" @click="editor.chain().focus().setTextAlign(item.value).run()")
      v-list-item-icon
        v-icon {{'mdi-format-align-'+item.value}}
      v-list-item-title(v-t="item.label")
</template>

<style lang="sass">

</style>
