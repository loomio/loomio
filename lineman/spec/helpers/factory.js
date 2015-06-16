window.useFactory = function() {
  inject(function(Records) {
    this.factory = {
      currentIds: {},
      create: function(model, attrs) {
        attrs = attrs || {}
        this.currentIds[model] = this.currentIds[model] || 1
        attrs.id = this.currentIds[model] || 1;
        attrs.key = "key" + attrs.id
        this.currentIds[model] = attrs.id + 1;
        return Records[_.camelCase(model)].initialize(_.extend(fixtures[model], attrs));
      },

      update: function(model, id, attrs) {
        return this.find(model, id).updateFromJSON(attrs || {});
      },

      createMany: function(model, attrs, n) {
        result = []
        for(var i = 0; i < n; i++) {
          result.push(this.create(model, attrs || {}));
        }
        return result;
      },

      find: function(model, id) {
        return Records[model].find(id);
      }
    }
  })

  fixtures = {
    users: {
      name: "Max Von Sydow",
      username: "mingthemerciless",
      avatar_initials: 'MVS',
      avatar_kind: 'initials'
    },

    memberships: {
      volume: 1,
      admin: false
    },

    groups: {
      name: 'Venus: ...Ladies.',
      description: '',
      created_at: moment().subtract(2, 'day'),
      updated_at: moment().subtract(2, 'day'),
      has_discussions: false
    },

    discussions: {
      title: 'Earth: The Most Recent Frontier',
      description: '',
      last_item_at: moment(),
      last_comment_at: moment(),
      last_activity_at: moment(),
      created_at: moment().subtract(2, 'day'),
      updated_at: moment().subtract(2, 'day'),
      first_sequence_id: 0,
      last_sequence_id: 50,
      salient_items_count: 50,
      private: false
    },

    discussion_readers: {
      discussion_id: 1,
      participating: false,
      starred: false,
      last_read_sequence_id: 50,
      read_salient_items_count: 50
    },

    proposals: {
      name: "To the robot moon!",
      closingAt: moment().add(3, 'day'),
      description: "Like astrobots!"
    },

    comments: {
      body: "Jello Swirled"
    },

    events: {

    }
  }
}
