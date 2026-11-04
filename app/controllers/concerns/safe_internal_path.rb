module SafeInternalPath
  private

  def safe_internal_path(*candidates)
    path = candidates.compact.first.to_s
    path if path.start_with?('/') && !path.start_with?('//', '/\\')
  end
end
