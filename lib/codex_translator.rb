# frozen_string_literal: true

require "open3"
require "tempfile"

# Sends a translation prompt to the codex CLI and returns the model's reply.
# The app string and user manual translators share it, so both use the same
# model: DOCS_TRANSLATOR_MODEL and DOCS_TRANSLATOR_EFFORT override the
# defaults for either. Plain Ruby, so the documentation tools can use it
# without booting Rails.
module CodexTranslator
  MODEL = "gpt-6.1-sol"
  EFFORT = "low"
  ROOT = File.expand_path("..", __dir__)

  def self.model
    ENV.fetch("DOCS_TRANSLATOR_MODEL", MODEL)
  end

  def self.call(prompt)
    Tempfile.create(["translation", ".json"]) do |output|
      arguments = [
        "exec",
        "-m", model,
        "-c", %(model_reasoning_effort="#{ENV.fetch("DOCS_TRANSLATOR_EFFORT", EFFORT)}"),
        "-s", "read-only", "--ephemeral", "--skip-git-repo-check",
        "-C", ROOT,
        "-o", output.path, "-"
      ]
      log, status = Open3.capture2e("codex", *arguments, stdin_data: prompt)
      raise "codex exec failed:\n#{log.lines.last(20).join}" unless status.success?

      File.read(output.path)
    end
  end
end
