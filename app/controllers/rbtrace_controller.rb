class RbtraceController < BaseController
  include ActionController::Live
 
  def new
    raise "not permitted pal" unless current_user.is_admin?

    make_dir
    filename = gen_filename
    filepath = tmp_dir.join(filename)

    require "objspace"
    require 'fog'

    ObjectSpace.trace_object_allocations_start
    GC.start()

    File.open(filepath, 'w') do |f|
      ObjectSpace.dump_all(output: f)
    end

    Thread.new do
      File.open(filepath, 'r') do |f|

        connection = Fog::Storage.new({
          :provider                 => 'AWS',
          :aws_access_key_id        => ENV['DUMP_AWS_ID'],
          :aws_secret_access_key    => ENV['DUMP_AWS_KEY']
        })

        d = connection.directories.get('lmo-tracedumps')

        d.files.create(key: filename, body: f, public: false)
        d.files.create(key: 'completed-'+filename, body: 'yes', public: false)
      end
    end

    render text: "wrote: #{filename}"
  end


  private
  def make_dir
    Dir.mkdir(Rails.root.join('tmp'))
  rescue SystemCallError
    false
  end

  def gen_filename
    request.host+"-heap#{Time.now.strftime('%Y-%m-%d_%H%M%S')}.json"
  end

  def tmp_dir
    Rails.root.join('tmp')
  end
end
