module Evergreen
  class Suite
    attr_reader :root, :runner, :server, :driver, :application

    def initialize(root)
      @root = root

      paths = [
        File.expand_path("config/evergreen.rb", root),
        File.expand_path(".evergreen", root),
        "#{ENV["HOME"]}/.evergreen"
      ]
      paths.each { |path| load(path) if File.exist?(path) }

      @runner = Runner.new(self)
      @server = Server.new(self)
      @application = Evergreen.application(self)
    end

    def run
      runner.run
    end

    def serve
      server.serve
    end

    def get_spec(name)
      Spec.new(self, name)
    end

    def get_jammit_files
      configuration_path = File.join(root,'config','assets.yml')
      return [] unless File.exist?(configuration_path)

      yaml = YAML::load(File.open(configuration_path))
      # TODO: include packages conditionally, rather than lumping them all together
      javascript_paths = yaml['javascripts'].values.flatten.uniq

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
