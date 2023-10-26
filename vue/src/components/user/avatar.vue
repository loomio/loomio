<script lang="js">
import Records from '@/shared/services/records';
import AppConfig from '@/shared/services/app_config';
import { pick } from 'lodash';

export default {
  props: {
    user: {
      type: Object,
      default() { return Records.users.build(); }
    },

    coordinator: Boolean,
    size: {
      type: Number,
      default: 36
    },
    noLink: Boolean,
    colors: Object
  },

  computed: {
    fontSize() {
      if (this.size < 19) { return '6px'; }
      if (this.size < 21) { return '8px'; }
      if (this.size < 25) { return '10px'; }
      if (this.size < 33) { return '12px'; }
      if (this.size < 48) { return '14px'; }
      if (this.size < 64) { return '18px'; }
      if (this.size < 128) { return '32px'; }
      return '50px';
    },

    imageUrl() {
      if (this.size > 64) {
        return this.user.avatarUrl;
      } else {
        return this.user.thumbUrl;
      }
    },

    color() {
      const colors = Object.values(pick(AppConfig.theme.brand_colors, ['gold', 'sky', 'wellington', 'sunset']));
      return colors[(this.user.id || 0) % colors.length];
    },

    componentType() {
      if (this.noLink || !this.user.id) {
        return 'div';
      } else {
        return 'router-link';
      }
    }
  }
}

</script>

<template lang="pug">
component.user-avatar(aria-hidden="true" :is="componentType" :to="!noLink && user.id && urlFor(user)" :style="{ 'width': size + 'px', margin: '0' }")
  v-avatar(v-if="imageUrl" :title='user.name' :size='size')
    img(:alt='user.avatarInitials' :src='imageUrl')
  v-avatar(v-else :title='user.name' :size='size' :color="color")
    span.user-avatar--initials(v-if="user.avatarKind == 'initials'" :style="{'font-size': fontSize, width: size+'px', height: size+'px'}") {{user.avatarInitials}}
    v-icon(v-else) {{user.avatarKind}}
</template>

<style lang="sass">
.v-avatar
  img
    object-fit: cover
.user-avatar--initials
  color: rgba(0,0,0,.88)
  font-size: 15px
  display: flex
  align-items: center
  justify-content: center

</style>
