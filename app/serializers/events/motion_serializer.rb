class Events::MotionSerializer < Events::BaseSerializer
  has_one :discussion
  has_one :eventable, polymorphic: true, root: :proposals # instead of storing it in 'motions'
end
