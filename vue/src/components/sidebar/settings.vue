<script setup>
import AppConfig       from '@/shared/services/app_config';
import Session         from '@/shared/services/session';
import Records         from '@/shared/services/records';
import Flash from '@/shared/services/flash';

import { reactive, computed } from 'vue'
import { useTheme } from 'vuetify';
const theme = useTheme();

const togglePinned = function() {
  if (Session.user().experiences['sidebar']) {
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


const canStartDemo = computed(() => AppConfig.features.app.demos );
const version = computed(() => AppConfig.version );
const release = computed(() => AppConfig.release );
const siteName = computed(() => AppConfig.theme.site_name );
const user = computed(() => Session.user() );
const showHelp = computed(() => AppConfig.features.app.help_link );
const helpURL = computed(() => {
  const siteUrl = new URL(AppConfig.baseUrl);
  return `https://help.loomio.com/en/?utm_source=${siteUrl.host}`;
})
const showContact = computed(() => AppConfig.features.app.show_contact );
</script>

<template lang="pug">
v-list(nav density="comfortable")
  v-list-item(@click="$emit('closeSettings')")
    template(v-slot:append)
      common-icon(name="mdi-close")
    v-list-item-title(v-t="'sidebar.user_settings'")
  v-list-item.user-dropdown__list-item-button--profile(to="/profile")
    template(v-slot:prepend)
      common-icon(name="mdi-account")
    v-list-item-title(v-t="'user_dropdown.edit_profile'")
  v-list-item.user-dropdown__list-item-button--email-settings(to="/email_preferences")
    template(v-slot:prepend)
      common-icon(name="mdi-cog-outline")
    v-list-item-title(v-t="'user_dropdown.email_settings'")
  v-list-item(v-if="!user.experiences['sidebar']" @click="togglePinned")
    template(v-slot:prepend)
      common-icon(name="mdi-pin")
    v-list-item-title(v-t="'user_dropdown.pin_sidebar'")
  v-list-item(v-if="user.experiences['sidebar']" @click="togglePinned")
    template(v-slot:prepend)
        common-icon(name="mdi-pin-off")
    v-list-item-title(v-t="'user_dropdown.unpin_sidebar'")
  v-list-item(@click="signOut()")
    template(v-slot:prepend)
      common-icon(name="mdi-exit-to-app")
    v-list-item-title(v-t="'user_dropdown.sign_out'")

  v-divider
  v-list-subheader(v-t="'user_dropdown.theme'")

  v-list-item(@click="setTheme('light')" :title="$t('user_dropdown.light')")
    template(v-slot:prepend)
      common-icon(name="mdi-white-balance-sunny" color="#DCA034")

  v-list-item(@click="setTheme('lightBlue')")
    v-list-item-title Light blue
    template(v-slot:prepend)
      common-icon(name="mdi-white-balance-sunny" color="#658AE7")

  v-list-item(@click="setTheme('dark')" :title="$t('user_dropdown.dark')")
    template(v-slot:prepend)
      common-icon(name="mdi-weather-night" color="#DCA034")

  v-list-item(@click="setTheme('darkBlue')")
    v-list-item-title Dark blue
    template(v-slot:prepend)
      common-icon(name="mdi-weather-night" color="#658AE7")

  v-divider
  v-list-item(href="https://github.com/loomio/loomio/releases" target="_blank" lines="two")
    v-list-item-title
      | Loomio version
    v-list-item-subtitle
      span {{version}}

</template>
