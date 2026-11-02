require "test_helper"
require "rake"
require "tmpdir"

class TranslateStringsTaskTest < ActiveSupport::TestCase
  setup do
    @locales_previous = ENV["LOCALES"]
    ENV["LOCALES"] = "fr"
    Rake::Task.define_task(:environment) unless Rake::Task.task_defined?(:environment)
    load Rails.root.join("lib/tasks/loomio.rake") unless Rake::Task.task_defined?("loomio:translate_strings")
    @task = Rake::Task["loomio:translate_strings"]
    @task.reenable
  end

  teardown do
    @locales_previous.nil? ? ENV.delete("LOCALES") : ENV["LOCALES"] = @locales_previous
    @task.reenable
  end

  test "missing time zone labels are translated into their own file without rewriting client or server strings" do
    key = "timezones.timezones.regions.Europe/London"
    translator = AppStringTranslator.new("fr", existing: {}, translator: ->(prompt) {
      assert_includes prompt, key
      {key => "Londres"}.to_json
    })

    Dir.mktmpdir do |directory|
      Dir.chdir(directory) do
        FileUtils.mkdir_p("config/locales")
        %w[client server].each do |kind|
          File.write("config/locales/#{kind}.en.yml", {"en" => {"save" => "Save"}}.to_yaml)
          File.write("config/locales/#{kind}.fr.yml", {"fr" => {"save" => "Enregistrer"}}.to_yaml)
        end
        File.write("config/locales/timezones.en.yml", {"en" => {"timezones" => {"regions" => {"Europe/London" => "London", "Europe/Paris" => "Paris"}}}}.to_yaml)
        File.write("config/locales/timezones.fr.yml", {"fr" => {"timezones" => {"regions" => {"Europe/Paris" => "Paris"}}}}.to_yaml)
        unchanged = %w[client server].to_h { |kind| [kind, File.read("config/locales/#{kind}.fr.yml")] }

        AppStringTranslator.stub(:new, translator) { capture_io { @task.invoke } }

        labels = YAML.load_file("config/locales/timezones.fr.yml").fetch("fr").fetch("timezones").fetch("regions")
        assert_equal({"Europe/London" => "Londres", "Europe/Paris" => "Paris"}, labels)
        unchanged.each { |kind, content| assert_equal content, File.read("config/locales/#{kind}.fr.yml") }
      end
    end
  end
end
