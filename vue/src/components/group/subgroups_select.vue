<script lang="coffee">
export default
  props:
    group: Object
  computed:
    parentName: -> @group.parentOrSelf().name

    parentLinks: ->
      [
        name: @group.parentOrSelf().name
        path: @urlFor(@group.parentOrSelf(), @action)
      ,
        name: 'discussions_panel.include_subgroups_mine'
        path: @urlFor(@group.parentOrSelf(), @action, {subgroups: 'mine'})
      ,
        name: 'discussions_panel.include_subgroups_all'
        path: @urlFor(@group.parentOrSelf(), @action, {subgroups: 'all'})
      ]
    subgroupLinks: ->
      @group.parentOrSelf().subgroups().map (subgroup) =>
        {name: subgroup.name, path: @urlFor(subgroup)}


</script>

<template lang="pug">
v-menu
  template(v-slot:activator="{on}")
    v-btn(icon v-on="on")
      v-icon mdi-menu-down
  v-list
    v-list-item(v-for="link in parentLinks" :to="link.path" v-t="{path: link.name, args: {name: parentName}}")
    v-divider
    v-subheader(v-t="'group_page.subgroups'")
    v-list-item(v-for="link in subgroupLinks" :to="link.path" v-t="link.name")

</template>
