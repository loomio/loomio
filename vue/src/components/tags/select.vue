<script lang="js">
import Records        from '@/shared/services/records';
import Session        from '@/shared/services/session';
import EventBus       from '@/shared/services/event_bus';
import AbilityService from '@/shared/services/ability_service';
import AppConfig      from '@/shared/services/app_config';
import { ContainerMixin, HandleDirective } from 'vue-slicksort';

export default {
  props: {
    group: {
      type: Object,
      required: true
    },
    close: Function
  },

  directives: {
    handle: HandleDirective
  },

  data() {
    return {allTags: this.group.tags()};
  },

  mounted() {
    this.watchRecords({
      key: 'tags'+this.group.id,
      collections: ['tags'],
      query: () => {
        return this.allTags = this.group.tags();
      }
    });
  },

  computed: {
    canAdminTags() {
      return this.group.adminsInclude(Session.user());
    }
  },

  methods: {
    query() {
      this.allTags = this.group.tags();
    },

    openNewTagModal() {
      EventBus.$emit('openModal', {
        component: 'TagsModal',
        props: {
          tag: Records.tags.build({groupId: this.group.id}),
          close: () => {
            EventBus.$emit('openModal', {
              component: 'TagsSelect',
              props: {
                group: this.group
              }
            });
          }
        }
      });
    },

    openEditTagModal(tag) {
      EventBus.$emit('openModal', {
        component: 'TagsModal',
        props: {
          tag: tag.clone(),
          close: () => {
            EventBus.$emit('openModal', {
              component: 'TagsSelect',
              props: {
                group: this.group
              }
            });
          }
        }
      });
    },

    submit() {
      EventBus.$emit('closeModal');
    },

    sortEnded() {
      setTimeout(() => {
        Records.remote.post('tags/priority', {
          group_id: this.group.id,
          ids: this.allTags.map(t => t.id)
        });
      });
    }
  }
};

</script>
<template>

<v-card class="tags-modal">
  <v-card-title>
    <h1 class="headline" tabindex="-1" v-t="'loomio_tags.card_title'"></h1>
    <v-spacer></v-spacer>
    <dismiss-modal-button :close="close"></dismiss-modal-button>
  </v-card-title>
  <div class="px-4 pb-2">
    <p class="text--secondary"><span v-if="canAdminTags" v-t="'loomio_tags.helptext'"></span><span v-else v-t="{path: 'loomio_tags.only_admins_can_edit_tags', args: {group: group.parentOrSelf().name}}"></span></p>
  </div>
  <div v-if="canAdminTags">
    <div class="pa-4" v-if="allTags.length == 0">
      <p class="text--secondary" v-t="'loomio_tags.no_tags_in_group'"></p>
    </div>
    <sortable-list v-model="allTags" :useDragHandle="true" @sort-end="sortEnded" append-to=".app-is-booted" lock-axis="y" axis="y">
      <sortable-item v-for="(tag, index) in allTags" :index="index" :key="tag.id">
        <v-list-item>
          <div class="handle" v-handle="v-handle">
            <common-icon name="mdi-drag-vertical"></common-icon>
          </div>
          <v-chip :color="tag.color" v-handle="v-handle" outlined="outlined">{{tag.name}}</v-chip>
          <v-spacer></v-spacer>
          <v-btn icon="icon" @click="openEditTagModal(tag)">
            <common-icon class="text--secondary" name="mdi-pencil"></common-icon>
          </v-btn>
        </v-list-item>
      </sortable-item>
    </sortable-list>
    <v-card-actions>
      <v-spacer></v-spacer>
      <v-btn class="tag-form__new-tag" color="primary" @click="openNewTagModal" v-t="'loomio_tags.new_tag'"></v-btn>
    </v-card-actions>
  </div>
</v-card>
</template>
