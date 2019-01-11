urlFor = require 'vue/mixins/url_for'

module.exports =
  mixins: [urlFor]
  props:
    thread: Object
    user: Object
    coordinator: Boolean
    size: String
    noLink: Boolean
    colors: Object
  computed:
    threadUrl: -> "/d/#{this.thread.key}"
    boxClass: -> "lmo-box--#{this.size}"
  template: """
<div aria-hidden="true" :title="user.name" class="user-avatar" :class="[boxClass]">
    <a :href="urlFor(user)" v-if="!noLink" class="user-avatar__profile-link">
        <user-avatar-body :user="user" :coordinator="coordinator" :size="size" :colors="colors"></user-avatar-body>
    </a>
    <div v-if="noLink" class="user-avatar__profile-link">
        <user-avatar-body :user="user" :coordinator="coordinator" :size="size" :colors="colors"></user-avatar-body>
    </div>
</div>
"""
