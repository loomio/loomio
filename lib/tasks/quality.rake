begin
  require 'cane/rake_task'

  Cane::RakeTask.new(:cane) do |cane|
    cane.abc_max = 10
    cane.style_measure = 120
    cane.add_threshold 'coverage/covered_percent', :>=, 94.3
  end

  desc "run all quality metrics"
  task :quality => [:spec, :cane]

  task :default => :quality

rescue LoadError
  warn "cane not available, quality task not provided."
end
