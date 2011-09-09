module Evergreen
  class Server
    attr_reader :suite

    def initialize(suite)
      @suite = suite
    end

    def serve
      server.boot
      Launchy.open(server.url('/'))
      puts "Starting server at 127.0.0.1:#{server.port}"
      trap("INT"){ @kill = true }
      while !@kill do
        sleep 1
      end
    end

  protected

    def server
      @server ||= Capybara::Server.new(suite.application)
    end
  end
end
