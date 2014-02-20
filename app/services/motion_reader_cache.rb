class MotionReaderCache
  attr_accessor :user
  attr_accessor :readers

  def initialize(user, readers)
    @user = user
    @readers = readers
    @readers_by_motion_id = {}
    @readers.each do |reader|
      @readers_by_motion_id[reader.motion_id] = reader
    end
  end

  def get_for(motion)
    @readers_by_motion_id.fetch(motion.id) { new_reader_for(motion) }
  end

  private

  def new_reader_for(motion)
    mr = MotionReader.new
    mr.motion = motion
    mr.user = user
    mr
  end
end
