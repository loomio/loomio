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

<template>

<v-menu>
  <template v-slot:activator="{ on, attrs }">
    <div class="rounded-lg">
      <v-btn class="drop-down-button" small="small" icon="icon" v-on="on" :outlined="showOutline" :title="$t('formatting.alignment')">
        <common-icon small="small" :name="'mdi-format-align-'+current"></common-icon>
      </v-btn>
    </div>
  </template>
  <v-list dense="dense">
    <v-list-item v-for="(item, index) in alignments" :key="index" :class="{ 'v-list-item--active': editor.isActive({ textAlign: item.value }) }" @click="editor.chain().focus().setTextAlign(item.value).run()">
      <v-list-item-icon>
        <common-icon small="small" :name="'mdi-format-align-'+item.value"></common-icon>
      </v-list-item-icon>
      <v-list-item-title v-t="item.label"></v-list-item-title>
    </v-list-item>
  </v-list>
</v-menu>
</template>

<style lang="sass">

</style>
