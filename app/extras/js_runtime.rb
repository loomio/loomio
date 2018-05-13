module JSRuntime
  include AngularHelper

  # So functional!
  def eval(command, input)
    cleanup perform build(command, input)
  rescue => e
    Raven.capture_exception(e)
    input
  end

  private

  def build(command, input)
    command.gsub("?", prepare(input))
  end

  def prepare(input)
    input.to_s.strip.gsub("\"", "{{DOUBLE_QUOTE}}")
                    .gsub("\r", "{{CARRIAGE_RETURN}}")
                    .gsub("\n", "{{LINE_FEED}}")
                    .gsub("\u2028", "{{LINE_SEPARATOR}}")
                    .gsub("\u2029", "{{PARAGRAPH_SEPARATOR}}")
  end

  def perform(command)
    runtime.eval(command)
  end

  def cleanup(result)
    result.gsub("{{DOUBLE_QUOTE}}", "\"")
          .gsub("{{LINE_FEED}}", "\n")
          .gsub("{{CARRIAGE_RETURN}}", "\r")
          .gsub("{{LINE_SEPARATOR}}", "\u2028")
          .gsub("{{PARAGRAPH_SEPARATOR}}", "\u2029")
  end

  def runtime
    @runtime ||= ExecJS.compile(execjs_asset)
  end

  def execjs_asset
    File.read [:public, client_asset_path(:"execjs.bundle.min.js")].join('/').squeeze('/')
  end

end
