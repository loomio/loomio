require 'rspec/autorun'

def needs(path_fragment)
  full_path = File.expand_path(Dir.pwd + '/app/' + path_fragment)
  unless $LOAD_PATH.include?(full_path)
    $LOAD_PATH.unshift full_path
  end
end
