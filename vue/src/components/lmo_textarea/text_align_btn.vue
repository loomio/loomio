<script lang="js">
export default
{
  props: {
    editor: Object
  },

  methods: {
    isActive(alignment) {
      return this.editor.isActive({ textAlign: alignment });
    }
  },

  computed: {
    showOutline() {
      return this.editor.isActive({ textAlign: 'right' }) || this.editor.isActive({ textAlign: 'center' });
    },

    current() {
      return ['left', 'center', 'right'].find(v => this.isActive(v)) || "left";
    },

    alignments() {
      return [
        { label: 'formatting.left_align', value: 'left' },
        { label: 'formatting.center_align', value: 'center' },
        { label: 'formatting.right_align', value: 'right' },
      ];
    }
  }
};

</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{ props }")
    v-btn.drop-down-button(v-bind="props" size="x-small" variant="text" icon :outlined="showOutline" :title="$t('formatting.alignment')")
      common-icon(size="small" :name="'mdi-format-align-'+current")
  v-list(density="compact")
    v-list-item(v-for="(item, index) in alignments" :key="index" :class="{ 'v-list-item--active': editor.isActive({ textAlign: item.value }) }" @click="editor.chain().focus().setTextAlign(item.value).run()")
      template(v-slot:prepend)
        common-icon(size="small" :name="'mdi-format-align-'+item.value")
      v-list-item-title(v-t="item.label")
</template>

<style lang="sass">

</style>
