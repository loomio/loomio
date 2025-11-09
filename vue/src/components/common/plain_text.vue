<script lang="js">
export default {
  props: {
    model: Object,
    field: String
  },

  methods: {
    decodeHTMLEntities(str) {
      var parser = new DOMParser();
      var doc = parser.parseFromString(str, 'text/html');
      return doc.body.textContent || doc.body.innerText;
    }
  },
  computed: {
    content() {
      if (this.model.translationId) {
        return this.decodeHTMLEntities(this.model.translation().fields[this.field]);
      } else {
        return this.decodeHTMLEntities(this.model[this.field]);
      }
    },
  }
}
</script>

<template lang="pug">
span.plain-text {{content}}
</template>
