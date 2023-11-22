<script lang="js">
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

  computed: {
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
<template>

<div>
  <template v-if="editing">
    <v-card class="link-preview mt-3" outlined="outlined" style="position: relative">
      <div class="link-preview__image" v-if="preview.image" :style="{'background-image': 'url('+preview.image+')', 'background-size': (preview.fit || 'contain'), 'background-position': (preview.align || 'center')}"></div>
      <v-btn class="link-preview__btn" color="primary" icon="icon" outlined="outlined" :title="$t('common.action.done')" style="right: 8px" @click="editing = false">
        <common-icon name="mdi-check"></common-icon>
      </v-btn>
      <v-card-title>
        <v-text-field filled="filled" v-model="preview.title"></v-text-field>
      </v-card-title>
      <v-card-subtitle>
        <v-textarea filled="filled" v-model="preview.description"></v-textarea>
      </v-card-subtitle>
    </v-card>
  </template>
  <template v-else>
    <v-card class="link-preview link-preview-link mt-3" outlined="outlined" style="position: relative">
      <template v-if="remove">
        <v-btn class="link-preview__btn" color="primary" outlined="outlined" style="right: 8px" icon="icon" @click="remove(preview.url)" :title="$t('common.action.remove')">
          <common-icon name="mdi-close"></common-icon>
        </v-btn>
        <v-btn class="link-preview__btn" color="primary" style="right: 48px" icon="icon" outlined="outlined" @click="editing = true" :title="$t('common.action.edit')">
          <common-icon name="mdi-pencil"></common-icon>
        </v-btn>
        <template v-if="preview.image">
          <v-btn class="link-preview__btn" @click="preview.fit = (preview.fit == 'cover' ? 'contain' : 'cover')" color="primary" icon="icon" outlined="outlined" style="right: 88px" :title="$t('common.action.zoom')">
            <common-icon v-if="preview.fit == 'contain'" name="mdi-magnify-plus-outline"></common-icon>
            <common-icon v-else name="mdi-magnify-minus-outline"></common-icon>
          </v-btn>
          <v-btn class="link-preview__btn" v-if="preview.fit == 'cover'" @click="preview.align = (preview.align == 'top' ? 'center' : 'top')" color="primary" icon="icon" outlined="outlined" style="right: 128px" :title="$t('common.action.align')">
            <common-icon v-if="preview.align == 'top'" name="mdi-format-vertical-align-center"></common-icon>
            <common-icon v-else name="mdi-format-vertical-align-top"></common-icon>
          </v-btn>
        </template>
      </template><a class="link-preview-link" :href="preview.url" target="_blank" rel="nofollow ugc noreferrer noopener">
        <div class="ml-4"></div>
        <div class="link-preview__image" v-if="preview.image" :style="{'background-image': 'url('+preview.image+')', 'background-size': (preview.fit || 'contain'), 'background-position': (preview.align || 'center')}"></div>
        <v-card-title class="text--secondary">
          <common-icon class="mr-1" name="mdi-open-in-new"></common-icon>{{preview.title}}
        </v-card-title>
        <v-card-subtitle><span v-if="doctype.name != 'other'" v-t="'doctypes.'+doctype.name"></span><span class="link-preview__hostname" v-else v-html="preview.hostname"></span></v-card-subtitle>
        <v-card-text class="text--secondary" v-if="preview.description">{{preview.description}}</v-card-text></a>
    </v-card>
  </template>
</div>
</template>

<style lang="sass">
.link-preview
  overflow-wrap: break-word
  word-wrap: break-word
  word-break: break-word
//   opacity: 70%
//
// .link-preview-link:hover
//   opacity: 100%

.link-preview__image
  height: 160px
  overflow: none
  background-position: center
  // max-width: 512px
  // margin: 0 auto
.link-preview__btn
  top: 8px
  position: absolute
</style>
