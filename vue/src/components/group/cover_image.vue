<script lang="coffee">
export default
  props:
    group: Object
</script>

<template lang="pug">
//- div(style="width: 100%; height: 200px;background-image: url(https://loomio-uploads.s3.amazonaws.com/groups/cover_photos/000/000/002/largedesktop/IMG_6150.JPG?1551260138);    position: absolute; width: 100%; min-width: 100%; background-size: cover; background-repeat: no-repeat; background-position: top center;") hello
.group-cover-image
  v-img(height="320px" :src="group.coverUrl()")
</template>
