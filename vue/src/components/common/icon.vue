<script lang="js">
import { camelCase } from 'lodash-es';

var once = false;
var icons = null;

export default {
  props: {
    color: {
      type: String,
      default: undefined
    },
    dense:  {
      type: Boolean,
      default: false
    },
    disabled:  {
      type: Boolean,
      default: false
    },
    large:  {
      type: Boolean,
      default: false
    },
    left:  {
      type: Boolean,
      default: false
    },
    light:  {
      type: Boolean,
      default: false
    },
    right:  {
      type: Boolean,
      default: false
    },
    size: {
      type: [Number, String],
      default: undefined
    },
    small: {
      type: Boolean,
      default: false
    },
    tag: String,
    XLarge:  {
      type: Boolean,
      default: false
    },
    XSmall: {
      type: Boolean,
      default: false
    },
    name: String
  },

  data() {
    return { loaded: false }
  },

  created() {
    if (!once) {
      once = true;
      import('/src/shared/services/icons.js').then(data => { icons = data.default });
    }

    this.checkLoaded();
  },
  methods: {
    iconSVG() { return icons[camelCase(this.name)] },
    checkLoaded() {
      if (icons) {
        this.loaded = true;
      } else {
        setTimeout(() => { this.checkLoaded() }, 500);
      }
    }
  }
};
</script>

<template lang="pug">
v-icon(
  v-if="loaded"
  color="color"
  :dense="dense"
  :large="large"
  :left="left"
  :light="light"
  :right="right"
  :small="small"
  :tag="tag"
  :x-large="XLarge"
  :x-small="XSmall"
  :size="size"
) {{ iconSVG() }}
</template>
