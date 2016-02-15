module JSRuntime
  include AngularHelper

  # So functional!
  def eval(command, input)
    cleanup perform build(command, input)
  rescue => e
    Airbrake.notify e
    input
  end

  private

  def build(command, input)
    command.gsub("?", prepare(input))
  end

  def prepare(input)
    input.to_s.strip.gsub("\"", "{{DOUBLE_QUOTE}}")
                    .gsub("\n", "{{LINE_BREAK}}")
  end

  def perform(command)
    runtime.eval(command)
  end

  def cleanup(result)
    result.gsub("{{DOUBLE_QUOTE}}", "\"")
          .gsub("{{LINE_BREAK}}", "\n")
  end

  def runtime
    @runtime ||= ExecJS.compile(execjs_asset)
  end

  def execjs_asset
    File.read [:public, client_asset_path(:"execjs.min.js")].join('/')
  end

end
