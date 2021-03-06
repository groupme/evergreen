module Evergreen
  class Suite
    attr_reader :driver

    def initialize
      paths = [
        File.expand_path("config/evergreen.rb", root),
        File.expand_path(".evergreen", root),
        "#{ENV["HOME"]}/.evergreen"
      ]
      paths.each { |path| load(path) if File.exist?(path) }
    end

    def root
      Evergreen.root
    end

    def mounted_at
      Evergreen.mounted_at
    end

    def get_spec(name)
      Spec.new(self, name)
    end

    def get_jammit_files(package="application")
      configuration_path = File.join(root,'config','assets.yml')
      return [] unless File.exist?(configuration_path)

      yaml = YAML::load(File.open(configuration_path))

      javascript_paths = yaml['javascripts'][package]

      all_filenames = javascript_paths.map do |filename|
        Dir[File.join(root,filename)]
      end.flatten.uniq

      all_filenames.reject! do |filename|
        filename.match(/\.mustache$/)
      end

      # TODO: don't hardcode the path name
      all_filenames.map do |filename|
        filename.split(File.join(root,"public")).last
      end
    end

    def specs
      s = Dir.glob(File.join(root, Evergreen.spec_dir, '**/*_spec.{js,coffee}')).map do |path|
        Spec.new(self, path.gsub(File.join(root, Evergreen.spec_dir, ''), ''))
      end
      s.reject! { |spec| spec.name != ENV['SPEC'] } if ENV['SPEC']
      s
    end

    def templates
      Dir.glob(File.join(root, Evergreen.template_dir, '*')).map do |path|
        Template.new(self, File.basename(path))
      end
    end
  end
end
