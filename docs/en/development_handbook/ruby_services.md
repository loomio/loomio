# Services in the Loomio rails app

If you're new to service objects, the incredible blog post [7 Patterns to Refactor ActiveRecord Models](http://blog.codeclimate.com/blog/2012/10/17/7-ways-to-decompose-fat-activerecord-models/)
explains that Service Objects encapsulate an action in the system.

For example: An action such as _starting a thread_ involves checking permissions, creating or updating records, sending emails and so on.
We don't want that stuff in our models or controllers, so we make service objects to hold this logic and it becomes really easy to see what's going on.

You can write services however you like, but there is a specific pattern we tend to follow:

- file in app/services/{name}_service.rb
- methods are class/module methods
- use named parameters EG: def self.update(group:, params:, actor:)
- checks if actor has permission with authorize!
- saves the record returning false if invalid
- returns true or a newly created event record

Just to be clear: do not call `save!` or `update!` they raise error on validation which we don't want to do.

Have a look around: https://github.com/loomio/loomio/tree/master/app/services
