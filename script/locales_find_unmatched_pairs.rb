require 'yaml'

path = 'config/locales/'

def r_match(filename, h)
  h.each_pair do |k, v|
    if v.respond_to?(:each_pair)
      r_match(filename, v)
    else
      pairs = {
        '%{' => '}',
        '<' => '>',
        '"' => '"',
        '<p>' => '</p>',
        '<a' => '</a>'
      }
      pairs.each_pair do |left, right|
        if v && v.include?(left)
          if v && !v.include?(right)
            puts "#{filename} #{k}:, #{v}"
          end
        end
      end
    end
  end
end

Dir.glob(path+'*.yml').each do |filename|
  yml = YAML.load_file(filename)
  r_match(filename, yml)
end
