<script lang="js">
export default
{
  props: {
    group: Object
  },
  computed: {
    parentName() { return this.group.parentOrSelf().name; },

    parentLinks() {
      return [{
        name: this.group.parentOrSelf().name,
        path: this.urlFor(this.group.parentOrSelf(), this.action)
      }
      , {
        name: 'discussions_panel.include_subgroups_mine',
        path: this.urlFor(this.group.parentOrSelf(), this.action, {subgroups: 'mine'})
      }
      , {
        name: 'discussions_panel.include_subgroups_all',
        path: this.urlFor(this.group.parentOrSelf(), this.action, {subgroups: 'all'})
      }
      ];
    },
    subgroupLinks() {
      return this.group.parentOrSelf().subgroups().map(subgroup => {
        return {name: subgroup.name, path: this.urlFor(subgroup)};
      });
    }
  }
};
</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{on, attrs}")
    v-btn(icon v-on="on" v-bind="attrs")
      v-icon mdi-menu-down
  v-list
    v-list-item(v-for="link in parentLinks" :to="link.path" v-t="{path: link.name, args: {name: parentName}}")
    v-divider
    v-subheader(v-t="'group_page.subgroups'")
    v-list-item(v-for="link in subgroupLinks" :to="link.path" v-t="link.name")

</template>
