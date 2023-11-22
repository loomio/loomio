<script lang="js">
import AppConfig       from '@/shared/services/app_config';
import Session         from '@/shared/services/session';
import Records         from '@/shared/services/records';
import Flash from '@/shared/services/flash';

export default {
  methods: {
    togglePinned() {
      if (this.user.experiences['sidebar']) {
        return Records.users.saveExperience('sidebar', false);
      } else {
        return Records.users.saveExperience('sidebar', true);
      }
    },

    toggleDark() {
      if (this.isDark) {
        Records.users.saveExperience('darkMode', false);
        return this.$vuetify.theme.dark = false;
      } else {
        Records.users.saveExperience('darkMode', true);
        return this.$vuetify.theme.dark = true;
      }
    },

    defaultDark() {
      return (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
    },

    signOut() {
      return Session.signOut();
    }
  },

  computed: {
    isDark() { return this.$vuetify.theme.dark; },
    version() { return AppConfig.version; },
    release() { return AppConfig.release; },
    siteName() { return AppConfig.theme.site_name; },
    user() { return Session.user(); }
  }
};

</script>

<template>

<div class="user-dropdown">
  <v-list-item v-if="!user.experiences['sidebar']" @click="togglePinned" dense="dense">
    <v-list-item-title v-t="'user_dropdown.pin_sidebar'"></v-list-item-title>
    <v-list-item-icon>
      <common-icon name="mdi-pin"></common-icon>
    </v-list-item-icon>
  </v-list-item>
  <v-list-item v-if="user.experiences['sidebar']" @click="togglePinned" dense="dense">
    <v-list-item-title v-t="'user_dropdown.unpin_sidebar'"></v-list-item-title>
    <v-list-item-icon>
      <common-icon name="mdi-pin-off"></common-icon>
    </v-list-item-icon>
  </v-list-item>
  <v-list-item class="user-dropdown__list-item-button--profile" to="/profile" dense="dense">
    <v-list-item-title v-t="'user_dropdown.edit_profile'"></v-list-item-title>
    <v-list-item-icon>
      <common-icon name="mdi-account"></common-icon>
    </v-list-item-icon>
  </v-list-item>
  <v-list-item class="user-dropdown__list-item-button--email-settings" to="/email_preferences" dense="dense">
    <v-list-item-title v-t="'user_dropdown.email_settings'"></v-list-item-title>
    <v-list-item-icon>
      <common-icon name="mdi-cog-outline"></common-icon>
    </v-list-item-icon>
  </v-list-item>
  <v-list-item v-if="!isDark" @click="toggleDark" dense="dense">
    <v-list-item-title v-t="'user_dropdown.enable_dark_mode'"></v-list-item-title>
    <v-list-item-icon>
      <common-icon name="mdi-weather-night"></common-icon>
    </v-list-item-icon>
  </v-list-item>
  <v-list-item v-if="isDark" @click="toggleDark" dense="dense">
    <v-list-item-title v-t="'user_dropdown.disable_dark_mode'"></v-list-item-title>
    <v-list-item-icon>
      <common-icon name="mdi-white-balance-sunny"></common-icon>
    </v-list-item-icon>
  </v-list-item>
  <v-list-item @click="signOut()" dense="dense">
    <v-list-item-title v-t="'user_dropdown.sign_out'"></v-list-item-title>
    <v-list-item-icon>
      <common-icon name="mdi-exit-to-app"></common-icon>
    </v-list-item-icon>
  </v-list-item>
  <v-list-item href="https://github.com/loomio/loomio/releases" target="_blank" dense="dense" :title="release">
    <v-list-item-title class="text--secondary"><span v-t="'common.version'"></span>
      <space></space><span>{{version}}</span>
    </v-list-item-title>
  </v-list-item>
</div>
</template>
