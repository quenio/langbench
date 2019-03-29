module Text::File

  def file(path)
    File.open(path, 'r').read
  end

  def write_file(path, text)
    FileUtils.makedirs(File.dirname(path)) unless Dir.exists?(File.dirname(path))
    File.open(path, 'w') { |file| file.write(text) }
  end

end
