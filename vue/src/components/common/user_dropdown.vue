<script setup>
import AppConfig       from '@/shared/services/app_config';
import Session         from '@/shared/services/session';
import Records         from '@/shared/services/records';
import Flash from '@/shared/services/flash';

import { reactive, computed } from 'vue'
import { useTheme } from 'vuetify';
const theme = useTheme();

const togglePinned = function() {
  if (this.user.experiences['sidebar']) {
    return Records.users.saveExperience('sidebar', false);
  } else {
    return Records.users.saveExperience('sidebar', true);
  }
}

const toggleDark = function() {
  theme.global.name.value = theme.global.current.value.dark ? 'light' : 'dark'
  if (theme.global.name.value == 'light') {
    Records.users.saveExperience('darkMode', false);
  } else {
    Records.users.saveExperience('darkMode', true);
  }
}


const signOut = function() {
  return Session.signOut();
}

const version = computed(() => AppConfig.version );
const release = computed(() => AppConfig.release );
const siteName = computed(() => AppConfig.theme.site_name );
const user = computed(() => Session.user() );

</script>

<template lang="pug">
v-list-item(v-if="!user.experiences['sidebar']" @click="togglePinned" density="compact")
  v-list-item-title(v-t="'user_dropdown.pin_sidebar'")
  template(v-slot:append)
    common-icon(name="mdi-pin")
v-list-item(v-if="user.experiences['sidebar']" @click="togglePinned" density="compact")
  v-list-item-title(v-t="'user_dropdown.unpin_sidebar'")
  template(v-slot:append)
      common-icon(name="mdi-pin-off")
v-list-item.user-dropdown__list-item-button--profile(to="/profile" density="compact")
  v-list-item-title(v-t="'user_dropdown.edit_profile'")
  template(v-slot:append)
    common-icon(name="mdi-account")
v-list-item.user-dropdown__list-item-button--email-settings(to="/email_preferences" density="compact")
  v-list-item-title(v-t="'user_dropdown.email_settings'")
  template(v-slot:append)
    common-icon(name="mdi-cog-outline")
v-list-item(v-if="!theme.global.current.value.dark" @click="toggleDark" density="compact")
  v-list-item-title(v-t="'user_dropdown.enable_dark_mode'")
  template(v-slot:append)
      common-icon(name="mdi-weather-night")
v-list-item(v-if="theme.global.current.value.dark" @click="toggleDark" density="compact")
  v-list-item-title(v-t="'user_dropdown.disable_dark_mode'")
  template(v-slot:append)
      common-icon(name="mdi-white-balance-sunny")
v-list-item(@click="signOut()" density="compact")
  v-list-item-title(v-t="'user_dropdown.sign_out'")
  template(v-slot:append)
    common-icon(name="mdi-exit-to-app")
v-list-item(href="https://github.com/loomio/loomio/releases" target="_blank" density="compact")
  v-list-item-title.text--secondary
    span(v-t="'common.version'")
    space
    span {{version}}

</template>
