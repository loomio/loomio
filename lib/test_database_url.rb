module TestDatabaseUrl
  DATABASE_NAME_MAIN = "loomio_test"
  DATABASE_URL_PREFIX = "postgresql://localhost/"

  def self.resolve(root:)
    database_name = if File.file?(File.join(root, ".git"))
      worktree_database_name(root: root)
    else
      DATABASE_NAME_MAIN
    end

    "#{DATABASE_URL_PREFIX}#{database_name}"
  end

  def self.worktree_database_name(root:)
    root = File.expand_path(root)
    worktree_name = File.basename(root)
    worktree_name = File.basename(File.dirname(root)) if worktree_name == "loomio"

    database_suffix = worktree_name
      .downcase
      .gsub(/[^a-z0-9]+/, "_")
      .gsub(/\A_+|_+\z/, "")

    raise ArgumentError, "Worktree name must contain at least one letter or number" if database_suffix.empty?

    "loomio_test_#{database_suffix}"
  end
end
