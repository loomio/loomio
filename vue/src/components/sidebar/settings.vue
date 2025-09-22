<script setup>
import AppConfig       from '@/shared/services/app_config';
import Session         from '@/shared/services/session';
import Records         from '@/shared/services/records';
import { mdiClose } from '@mdi/js';

import { computed } from 'vue'
import { useTheme } from 'vuetify';
const theme = useTheme();

const unhideOnboarding = function() {
  return Records.users.saveExperience('hideOnboarding', false);
}

const setTheme = function(name) {
  theme.change(name);
  Records.users.saveExperience('theme', name);
}

const signOut = () => Session.signOut();

const version = computed(() => AppConfig.version );
const release = computed(() => AppConfig.release );
const user = computed(() => Session.user() );
</script>

<template lang="pug">
v-list(nav density="comfortable")
  v-list-item.sidebar-close-settings(@click="$emit('closeSettings')" :append-icon="mdiClose" :title="$t('sidebar.user_settings')")
  v-list-item.user-dropdown__list-item-button--profile(to="/profile")
    template(v-slot:prepend)
      common-icon(name="mdi-account")
    v-list-item-title(v-t="'user_dropdown.edit_profile'")
  v-list-item.user-dropdown__list-item-button--email-settings(to="/email_preferences")
    template(v-slot:prepend)
      common-icon(name="mdi-cog-outline")
    v-list-item-title(v-t="'user_dropdown.email_settings'")
  v-list-item(@click="signOut()")
    template(v-slot:prepend)
      common-icon(name="mdi-exit-to-app")
    v-list-item-title(v-t="'user_dropdown.sign_out'")

  v-divider
  v-list-subheader(v-t="'user_dropdown.theme'")

  v-list-item(@click="setTheme('light')" :title="$t('user_dropdown.light')")
    template(v-slot:prepend)
      common-icon(name="mdi-white-balance-sunny" color="#DCA034")

  v-list-item(@click="setTheme('lightBlue')" :title="$t('user_dropdown.light_blue')")
    template(v-slot:prepend)
      common-icon(name="mdi-white-balance-sunny" color="#658AE7")

  v-list-item(@click="setTheme('dark')" :title="$t('user_dropdown.dark')")
    template(v-slot:prepend)
      common-icon(name="mdi-weather-night" color="#DCA034")

  v-list-item(@click="setTheme('darkBlue')" :title="$t('user_dropdown.dark_blue')")
    template(v-slot:prepend)
      common-icon(name="mdi-weather-night" color="#658AE7")

  v-divider
  v-list-item(v-if="user.experiences.hideOnboarding" @click="unhideOnboarding" :title="$t('tips.hide.unhide_onboarding')")
  v-list-item(href="https://github.com/loomio/loomio/releases" target="_blank" lines="two" title="Loomio version" :subtitle="version")

</template>
