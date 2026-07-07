<script lang="js">
import Records      from '@/shared/services/records';
import Session      from '@/shared/services/session';
import EventBus     from '@/shared/services/event_bus';
import WatchRecords from '@/mixins/watch_records';

export default {
  mixins: [WatchRecords],

  props: {
    group: {
      type: Object,
      required: true
    },
    close: Function
  },

  data() {
    return {allTags: this.sortedTags()};
  },

  mounted() {
    this.watchRecords({
      key: 'tags'+this.group.id,
      collections: ['tags'],
      query: () => {
        return this.allTags = this.sortedTags();
      }
    });
  },

  computed: {
    canAdminTags() {
      return this.group.parentOrSelf().adminsInclude(Session.user());
    }
  },

  methods: {
    sortedTags() {
      const seen = {};
      return this.group.tags().filter(tag => {
        const name = tag.name.toLowerCase();
        if (seen[name]) { return false; }
        seen[name] = true;
        return true;
      }).sort((a, b) => a.name.localeCompare(b.name));
    },

    query() {
      this.allTags = this.sortedTags();
    },

    openNewTagModal() {
      EventBus.$emit('openModal', {
        component: 'TagsModal',
        props: {
          tag: Records.tags.build({groupId: this.group.parentOrSelf().id}),
          close: () => this.openTagsSelect()
        }
      });
    },

    openEditTagModal(tag) {
      EventBus.$emit('openModal', {
        component: 'TagsModal',
        props: {
          tag: tag.clone(),
          close: () => this.openTagsSelect()
        }
      });
    },

    openMergeTagModal(tag) {
      EventBus.$emit('openModal', {
        component: 'TagsMergeModal',
        props: {
          tag,
          group: this.group,
          close: () => this.openTagsSelect()
        }
      });
    },

    deleteTag(tag) {
      EventBus.$emit('openModal', {
        component: 'ConfirmModal',
        props: {
          close: () => this.openTagsSelect(),
          confirm: {
            submit: tag.destroy,
            text: {
              title:    'loomio_tags.destroy_tag',
              helptext: 'loomio_tags.destroy_helptext',
              submit:   'common.action.delete',
              flash:    'loomio_tags.tag_destroyed'
            }
          }
        }
      });
    },

    openTagsSelect() {
      EventBus.$emit('openModal', {
        component: 'TagsSelect',
        props: {
          group: this.group
        }
      });
    },

    submit() {
      EventBus.$emit('closeModal');
    }
  }
};

</script>
<template lang="pug">
v-card.tags-modal(:title="$t('loomio_tags.card_title')")
  template(v-slot:append)
    dismiss-modal-button(:close="close")

  .px-4.pb-2
    p.text-medium-emphasis
      span(v-if="canAdminTags" v-t="'loomio_tags.helptext'")
      span(v-else v-t="{path: 'loomio_tags.only_admins_can_edit_tags', args: {group: group.parentOrSelf().name}}")

  div(v-if="canAdminTags")
    .pa-4(v-if="allTags.length == 0")
      p.text-medium-emphasis(v-t="'loomio_tags.no_tags_in_group'")
    v-list
      v-list-item(v-for="tag in allTags" :key="tag.id")
        v-chip(:color="tag.color" outlined)
          span.text-on-surface {{tag.name}}
        template(v-slot:append)
          v-btn.tag-form__edit-tag(icon size="small" variant="text" :title="$t('common.action.edit')" @click="openEditTagModal(tag)")
            common-icon.text-medium-emphasis(name="mdi-pencil")
          v-btn.tag-form__merge-tag(icon size="small" variant="text" :title="$t('loomio_tags.merge')" @click="openMergeTagModal(tag)" :disabled="allTags.length < 2")
            common-icon.text-medium-emphasis(name="mdi-merge")
          v-btn.tag-form__delete(icon size="small" variant="text" :title="$t('common.action.delete')" @click="deleteTag(tag)")
            common-icon.text-medium-emphasis(name="mdi-delete")
      v-list-item.tag-form__new-tag.mb-4(@click="openNewTagModal")
        template(v-slot:prepend)
          common-icon(name="mdi-plus")
        span(v-t="'loomio_tags.new_tag'")
</template>
