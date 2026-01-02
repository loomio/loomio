<script lang="js">
import Session  from '@/shared/services/session';
import Records  from '@/shared/services/records';
import EventBus from '@/shared/services/event_bus';
import { capitalize } from 'lodash-es';
import AppConfig from '@/shared/services/app_config';
import Flash   from '@/shared/services/flash';
import md5 from "md5";

export default {
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
  },

  computed: {
    gravatarUrl() {
      const hash = md5(this.user.email.trim().toLowerCase());
      return `https://www.gravatar.com/avatar/${hash}?s=256`;
    }
  }
};

</script>
<template lang="pug">
v-card.change-picture-form(:title="$t('change_picture_form.title')")
  template(v-slot:append)
    dismiss-modal-button
  v-overlay(:value="uploading")
    v-progress-circular(size="64" :value="progress")
  v-card-text
    p.text-medium-emphasis(v-html="$t('change_picture_form.helptext')")
    v-list.change-picture-form__options-list
      v-list-item.change-picture-form__option(@click='selectFile()')
        template(v-slot:prepend)
          v-avatar
            common-icon(name="mdi-camera")
        v-list-item-title(v-t="'change_picture_form.use_uploaded'")
          input.hidden.change-picture-form__file-input(type="file" ref="fileInput" @change='uploadFile' accept="image/png, image/jpeg, image/webp")
      v-list-item.change-picture-form__option(v-if="previous_uploaded_avatar" @click="submit('uploaded')")
        template(v-slot:prepend)
          v-avatar
            v-img(cover :src="previous_uploaded_avatar")
        v-list-item-title(v-t="'change_picture_form.existing_upload'")
      v-list-item(v-for="provider in providers" :key="provider.id" @click="selectProvider(provider)")
        template(v-slot:prepend)
          v-avatar
            common-icon(:name=" iconClass(provider.name) ")
        v-list-item-title(v-t="{ path: 'change_picture_form.use_provider', args: { provider: capitalize(provider.name) } }")
      v-list-item.change-picture-form__option(@click="submit('gravatar')")
        template(v-slot:prepend)
          v-avatar
            v-img(:src="gravatarUrl")
        v-list-item-title(v-t="'change_picture_form.use_gravatar'")
      v-list-item.change-picture-form__option(@click="submit('initials')")
        template(v-slot:prepend).user-avatar
          v-avatar.user-avatar__initials--small {{user.avatarInitials}}
        v-list-item-title(v-t="'change_picture_form.use_initials'")
</template>
