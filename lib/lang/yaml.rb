require 'yaml'
require 'text/file'

module Lang::YAML

  include Text::File

  EXT = 'yml'.freeze

  def yaml_file(path)
    yaml(file(path))
  end

  def yaml(text)
    ::YAML.safe_load(text)
  end

end
