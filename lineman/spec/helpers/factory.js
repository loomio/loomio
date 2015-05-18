window.useFactory = function() {
  inject(function(Records) {
    this.factory = {
      currentIds: {},
      create: function(model, attrs) {
        attrs = attrs || {}
        this.currentIds[model] = this.currentIds[model] || 1
        attrs.id = this.currentIds[model] || 1;
        this.currentIds[model] = attrs.id + 1;
        return Records[model].initialize(_.extend(fixtures[model], attrs));
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
      avatarInitials: 'MVS',
      avatarKind: 'initials'
    },

    discussions: {
      key: 'abcdef',
      title: 'Earth: The Most Recent Frontier',
      description: '',
      lastItemAt: moment(),
      lastCommentAt: moment(),
      lastActivityAt: moment(),
      createdAt: moment().subtract(2, 'day'),
      updatedAt: moment().subtract(2, 'day'),
      private: false
    },

    comments: {
      body: "Jello Swirled"
    },

    events: {

    }
  }
}
