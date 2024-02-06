<script lang="js">
import { truncate } from 'lodash-es';

let doctypes = [];
import("@/../../config/doctypes.yml").then(function(data) {
  const keys = Object.keys(data).filter(k => parseInt(k).toString() === k);
  const values = keys.map(k => data[k]);
  return doctypes = values;
});



export default {
  props: {
    model: Object,
    preview: Object,
    remove: {
      default: null,
      type: Function
    }
  },

  data() {
    return {editing: false};
  },

  methods: { truncate },

  computed: {
    imageUrl() {
      if (!this.preview.image) { return null };
      if (this.preview.image.startsWith('http')){
        return this.preview.image;
      } else {
        return 'https://' +this.hostname + this.preview.image
      }
    },

    doctype() {
      return doctypes.find(dt => (new RegExp(dt.regex)).test(this.preview.url)) || {name: 'other'};
    },

    icon() {
      if (this.doctype) {
        return 'mdi-'+this.doctype.icon;
      } else {
        return 'mdi-link-variant';
      }
    },

    iconColor() { return this.doctype.icon; },

    hostname() {
      return new URL(this.preview.url).host;
    }
  }
};
</script>
<template lang="pug">
div
  template(v-if="editing")
    v-card.link-preview.mt-3(outlined style="position: relative")
      .link-preview__image(v-if="preview.image" :style="{'background-image': 'url('+imageUrl+')', 'background-size': (preview.fit || 'contain'), 'background-position': (preview.align || 'center')}")
      v-btn.link-preview__btn(color="primary" icon outlined
            :title="$t('common.action.done')"
            style="right: 8px"
            @click="editing = false")
        common-icon(name="mdi-check")
      v-card-title
        v-text-field(filled v-model="preview.title")
      v-card-subtitle
        v-textarea(filled v-model="preview.description")

  template(v-else)
    v-card.link-preview.link-preview-link.mt-3(outlined style="position: relative")
      template(v-if="remove")
        div(style="position: relative; float: right")
          v-btn.link-preview__btn.mr-1(style="position: relative" color="primary"
                icon
                outlined
                @click="editing = true"
                :title="$t('common.action.edit')")
            common-icon(name="mdi-pencil")
          v-btn.link-preview__btn.mr-1(style="position: relative" color="primary"
                outlined
                icon
                @click="remove(preview.url)"
                :title="$t('common.action.remove')")
            common-icon(name="mdi-close")

      a.link-preview-link(:href="preview.url" target="_blank" rel="nofollow ugc noreferrer noopener")
        div.d-sm-flex
          .link-preview__image.ml-sm-4(v-if="preview.image" style="min-width: 128px" :style="{'background-image': 'url('+imageUrl+')', 'background-size': (preview.fit || 'contain'), 'background-position': (preview.align || 'center')}")
          div
            v-card-title.text--secondary
              common-icon.mr-1(name="mdi-open-in-new")
              span(v-html="preview.title")
            v-card-subtitle
              span(v-if="doctype.name != 'other'" v-t="'doctypes.'+doctype.name")
              span.link-preview__hostname(v-else v-html="truncate(preview.hostname, {length: 240})")
            v-card-text.text--secondary(v-if="preview.description" v-html="truncate(preview.description, {length: 240})")
</template>

<style lang="sass">
.link-preview
  position: relative
  overflow-wrap: break-word
  word-wrap: break-word
  word-break: break-word

.link-preview__image
  height: 160px
  overflow: none
  background-position: center

.link-preview__btn
  top: 8px
  position: absolute

</style>
