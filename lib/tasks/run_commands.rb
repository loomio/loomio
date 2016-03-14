def run_commands(commands)
  commands.each do |command|
    puts "\n-> #{command}"
    return false unless system(command)
  end
end
