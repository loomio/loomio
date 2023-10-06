# I don't understand why I need this!
#
# Ruby 2.7.6 (and below) does not require this monkey patch.
# ruby 3.2.2 will break like so:
#
# NoMethodError:
#   undefined method `after_create' for {}:Hash
#
# and if I byebug in, it's coming from this code
#
# [418, 427] in /Users/rob/.rbenv/versions/3.2.2/lib/ruby/gems/3.2.0/gems/activesupport-7.0.4.2/lib/active_support/callbacks.rb
#    418:             [@override_target || target, block, @method_name, target]
#    419:           end
#    420: 
#    421:           def make_lambda
#    422:             lambda do |target, value, &block|
# => 423:               (@override_target || target).send(@method_name, target, &block)
#    424:             end
#    425:           end
#    426: 
#    427:           def inverted_lambda
#
# I've tried removing various gems that touch activerecord, but nothing seems to make a difference
# 
# The only thing I've ever changed that affected the behaviour is the ruby version.

class Hash
  def after_create(arg)
  end
  def after_update(arg)
  end
  def after_destroy(arg)
  end
end
