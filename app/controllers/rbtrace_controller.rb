class RbtraceController < BaseController
  include ActionController::Live
 
  def new
    raise "not permitted pal" unless current_user.is_admin?

    make_dir
    filename = gen_filename
    filepath = tmp_dir.join(filename)

    Thread.new do
      require "objspace"
      require 'net/scp'
      require 'zlib'

      ObjectSpace.trace_object_allocations_start
      GC.start()
      f = Zlib::GzipWriter.open(filepath)
      ObjectSpace.dump_all(output: f)

      response.headers['Content-Type'] = 'text/event-stream'
      Net::SCP.upload!(ENV['DUMP_HOST'],
                       ENV['DUMP_USER'],
                       filepath,
                       filename,
                       ssh: {password: ENV['DUMP_PASS']}) do |update|

        response.stream.write "This is a test Messagen"
      end

      response.stream.close
    end.join



    render text: ["dumped to: #{filepath}", result].inspect
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
