class RbtraceController < BaseController
  def new
    raise "not permitted pal" unless current_user.is_admin?
    filename = "heap#{Time.now.strftime('%Y-%m-%d_%H%M%S')}.json"

    Thread.new do
      require "objspace"
      ObjectSpace.trace_object_allocations_start
      GC.start()
      ObjectSpace.dump_all(output: File.open(, "w"))
    end.join
    render text: "dumped to: #{filename}"
  end

  private
  def gen_filename
    
  end

  def connection
    connection = Fog::Storage.new({
      provider: 'AWS',
      aws_access_key_id: Rails.application.secrets.aws_access_key_id,
      aws_secret_access_key: Rails.application.secrets.aws_secret_access_key
    })

    # First, a place to contain the glorious details
    directory = connection.directories.create(
      :key    => "fog-demo-#{Time.now.to_i}", # globally unique name
      :public => true
    )

    # list directories
    p connection.directories

    # upload that resume
    file = directory.files.create(
      :key    => 'resume.html',
      :body   => File.open("/path/to/my/resume.html"),
      :public => true
    )
  end
end
