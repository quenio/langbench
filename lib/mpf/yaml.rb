require 'yaml'
require 'mpf/external/text'

module MPF

  module YAML

    include External::Text

    def yaml_file(path)
      yaml(file(path))
    end

    def yaml(text)
      ::YAML.safe_load(text)
    end

  end

end