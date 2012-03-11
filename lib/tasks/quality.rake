begin
  require 'cane/rake_task'
  require 'support/flay_threshold'

  METRIC_THRESHOLDS = {
    :coverage => 86.8,
    :flay => 300,
    :complexity => 10,
    :line_length => 120
  }

  namespace :metrics do
    Cane::RakeTask.new(:cane) do |cane|
      cane.abc_max = METRIC_THRESHOLDS[:complexity]
      cane.style_measure = METRIC_THRESHOLDS[:line_length]
      cane.add_threshold 'coverage/covered_percent', :>=, METRIC_THRESHOLDS[:coverage]
    end

    task :flay do
      require "flay"
      flay = Flay.new
      flay.process(*Flay.expand_dirs_to_files(%w(app lib spec)))

      max_value = flay.masses.values.max
      threshold = METRIC_THRESHOLDS[:flay]

      raise FlayThresholdBreached.new(flay, max_value, threshold) if max_value > threshold
    end
  end

  desc "run all quality metrics"
  task :quality => [:spec, 'metrics:cane', 'metrics:flay']

  task :default => :quality

rescue LoadError => e
  puts "#{e.class.name}: #{e.message}"
end
