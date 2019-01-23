<style lang="scss">
@import "variables";

.user-avatar__profile-link {
  cursor: pointer;
  &:hover,
  &:active,
  &:visited {
    color: $primary-text-color;
    text-decoration: none !important;
  }
}

.user-avatar{
  box-sizing: border-box;
  text-align: center;
  i { line-height: 28px; }
}

.user-avatar__img {
  width: 100%;
  overflow: hidden;
  border-radius: 50%;
  border: 1px solid $border-color;
}

.user-avatar__initials {
  &.mdi {
    opacity: 0.8;
  }
  overflow: hidden;
  border-radius: 50%;
  color: $primary-text-color;
  text-decoration: none !important;
  border: 1px solid $border-color;
}

.user-avatar__initials--small{
  font-size: 12px;
  line-height: 30px;
}

.user-avatar__initials--medium{
  font-size: 20px;
  line-height: 50px;
}

.user-avatar__initials--large {
  font-size: 32px;
  line-height: 80px;
}

.user-avatar__initials--featured {
  font-size: 50px;
  line-height: 175px;
}

</style>

<script lang="coffee">
urlFor = require 'vue/mixins/url_for'

module.exports =
  mixins: [urlFor]
  props:
    thread: Object
    user: Object
    coordinator: Boolean
    size: String
    noLink: Boolean
    colors: Object
  computed:
    threadUrl: -> "/d/#{this.thread.key}"
    boxClass: -> "lmo-box--#{this.size}"
</script>

<template>
<div aria-hidden="true" :title="user.name" class="user-avatar" :class="[boxClass]">
    <router-link :to="urlFor(user)" v-if="!noLink" class="user-avatar__profile-link">
        <user-avatar-body :user="user" :coordinator="coordinator" :size="size" :colors="colors"></user-avatar-body>
    </router-link>
    <div v-if="noLink" class="user-avatar__profile-link">
        <user-avatar-body :user="user" :coordinator="coordinator" :size="size" :colors="colors"></user-avatar-body>
    </div>
</div>
</template>
