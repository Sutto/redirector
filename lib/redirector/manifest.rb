module Redirector
  class Manifest

    Redirect = Struct.new(:path, :url)

    # Conditions:
    # 1. Everything has a valid path.
    # 2. All URLs are valid

    attr_reader :redirects

    def initialize(contents)
      @redirects = contents.to_a.map { |(k,v)| Redirect.new k, v }.freeze
    end

    def validate
      @contents.each do |item|
      end
    end

    def self.load_file!(path)
      contents = JSON.parse File.read(path)
      new contents
    end

  end
end