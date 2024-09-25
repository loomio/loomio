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

const setTheme = function(name) {
  theme.global.name.value = name;
  Records.users.saveExperience('theme', name);
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
v-list-item(v-if="!user.experiences['sidebar']" @click="togglePinned")
  v-list-item-title(v-t="'user_dropdown.pin_sidebar'")
  template(v-slot:append)
    common-icon(name="mdi-pin")
v-list-item(v-if="user.experiences['sidebar']" @click="togglePinned")
  v-list-item-title(v-t="'user_dropdown.unpin_sidebar'")
  template(v-slot:append)
      common-icon(name="mdi-pin-off")
v-list-item.user-dropdown__list-item-button--profile(to="/profile")
  v-list-item-title(v-t="'user_dropdown.edit_profile'")
  template(v-slot:append)
    common-icon(name="mdi-account")
v-list-item.user-dropdown__list-item-button--email-settings(to="/email_preferences")
  v-list-item-title(v-t="'user_dropdown.email_settings'")
  template(v-slot:append)
    common-icon(name="mdi-cog-outline")
v-list-item(@click="signOut()")
  v-list-item-title(v-t="'user_dropdown.sign_out'")
  template(v-slot:append)
    common-icon(name="mdi-exit-to-app")

v-divider
v-list-subheader Theme


v-list-item(@click="setTheme('light')" density="compact")
  v-list-item-title Light gold
  template(v-slot:append)
      common-icon(name="mdi-white-balance-sunny" color="#DCA034")

v-list-item(@click="setTheme('lightBlue')" density="compact")
  v-list-item-title Light blue
  template(v-slot:append)
      common-icon(name="mdi-white-balance-sunny" color="#658AE7")
      
v-list-item(@click="setTheme('dark')" density="compact")
  v-list-item-title Dark gold
  template(v-slot:append)
    common-icon(name="mdi-weather-night" color="#DCA034")

v-list-item(@click="setTheme('darkBlue')" density="compact")
  v-list-item-title Dark blue
  template(v-slot:append)
    common-icon(name="mdi-weather-night" color="#658AE7")



v-list-item(href="https://github.com/loomio/loomio/releases" target="_blank" density="compact")
  v-list-item-title.text-medium-emphasis
    span(v-t="'common.version'")
    space
    span {{version}}

</template>
