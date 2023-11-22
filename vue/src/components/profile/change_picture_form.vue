<script lang="js">
import Session  from '@/shared/services/session';
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import Gravatar from 'vue-gravatar';
import { capitalize } from 'lodash-es';
import AppConfig from '@/shared/services/app_config';
import Flash   from '@/shared/services/flash';

export default {
  components: { Gravatar },
  data() {
    return {
      user: Session.user().clone(),
      providers: AppConfig.identityProviders,
      uploading: false,
      progress: 0,
      previous_uploaded_avatar: undefined
    };
  },
  methods: {
    capitalize,
    iconClass(provider) {
      return "mdi-" + ((provider === 'saml') ? 'key-variant' : provider);
    },

    providerColor(provider) {
      switch (provider) {
        case 'facebook': return '#3b5998';
        case 'google': return '#dd4b39';
        case 'slack': return '#e9a820';
        default:
          return this.$vuetify.theme.themes.light.primary;
      }
    },

    selectProvider(provider) {
      window.location = `${provider.href}?back_to=${window.location.href}`;
    },

    selectFile() {
      this.$refs.fileInput.click();
    },

    uploadFile() {
      this.uploading = true;
      Records.users.remote.onUploadSuccess = response => {
        Records.importJSON(response);
        EventBus.$emit('updateProfile');
        EventBus.$emit('closeModal');
        this.uploading = false;
      };
      Records.users.remote.upload('upload_avatar', this.$refs.fileInput.files[0], {}, args => { return this.progress = (args.loaded / args.total) * 100; });
    },

    submit(kind) {
      this.user.avatarKind = kind;
      Records.users.updateProfile(this.user).then(() => {
        Flash.success('profile_page.messages.picture_changed');
        EventBus.$emit('updateProfile');
        EventBus.$emit('closeModal');
      }).catch(() => true);
    }
  },

  created() {
    Records.users.saveExperience("changePicture");
    Records.users.fetch({path: 'avatar_uploaded'}).then(res => {
      this.previous_uploaded_avatar = res.avatar_uploaded; 
    });
  }
};

</script>
<template>

<v-card class="change-picture-form">
  <v-overlay :value="uploading">
    <v-progress-circular size="64" :value="progress"></v-progress-circular>
  </v-overlay>
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="'change_picture_form.title'"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button></dismiss-modal-button>
  </v-card-title>
  <v-card-text>
    <p class="text--secondary" v-html="$t('change_picture_form.helptext')"></p>
    <v-list class="change-picture-form__options-list">
      <v-list-item class="change-picture-form__option" @click="selectFile()">
        <v-list-item-avatar>
          <common-icon name="mdi-camera"></common-icon>
        </v-list-item-avatar>
        <v-list-item-title v-t="'change_picture_form.use_uploaded'">
          <input class="hidden change-picture-form__file-input" type="file" ref="fileInput" @change="uploadFile" accept="image/png, image/jpeg, image/webp"/>
        </v-list-item-title>
      </v-list-item>
      <v-list-item class="change-picture-form__option" v-if="previous_uploaded_avatar" @click="submit('uploaded')">
        <v-list-item-avatar><img :src="previous_uploaded_avatar"/></v-list-item-avatar>
        <v-list-item-title v-t="'change_picture_form.existing_upload'"></v-list-item-title>
      </v-list-item>
      <v-list-item v-for="provider in providers" :key="provider.id" @click="selectProvider(provider)">
        <v-list-item-avatar>
          <common-icon :name=" iconClass(provider.name) "></common-icon>
        </v-list-item-avatar>
        <v-list-item-title v-t="{ path: 'change_picture_form.use_provider', args: { provider: capitalize(provider.name) } }"></v-list-item-title>
      </v-list-item>
      <v-list-item class="change-picture-form__option" @click="submit('gravatar')">
        <v-list-item-avatar>
          <gravatar :email="user.email" :alt="user.name" :size="128"></gravatar>
        </v-list-item-avatar>
        <v-list-item-title v-t="'change_picture_form.use_gravatar'"></v-list-item-title>
      </v-list-item>
      <v-list-item class="change-picture-form__option" @click="submit('initials')">
        <v-list-item-avatar class="user-avatar">
          <v-avatar class="user-avatar__initials--small">{{user.avatarInitials}}</v-avatar>
        </v-list-item-avatar>
        <v-list-item-title v-t="'change_picture_form.use_initials'"></v-list-item-title>
      </v-list-item>
    </v-list>
  </v-card-text>
</v-card>
</template>
