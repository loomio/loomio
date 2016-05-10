module HasExperiences
  def experienced!(key, toggle = true)
    experiences[key] = toggle
    save
  end
end
