class RbtraceController < BaseController
  include ActionController::Live
 
  def new
    raise "not permitted pal" unless current_user.is_admin?

    make_dir
    filename = gen_filename
    filepath = tmp_dir.join(filename)

    require "objspace"
    require 'net/scp'
    require 'zlib'

    ObjectSpace.trace_object_allocations_start
    GC.start()
    f = Zlib::GzipWriter.open(filepath)
    ObjectSpace.dump_all(output: f)

    send_file(filepath)
  end


  private
  def make_dir
    Dir.mkdir(Rails.root.join('tmp'))
  rescue SystemCallError
    false
  end

  def gen_filename
    request.host+"-heap#{Time.now.strftime('%Y-%m-%d_%H%M%S')}.json.gz"
  end

  def tmp_dir
    Rails.root.join('tmp')
  end
end
