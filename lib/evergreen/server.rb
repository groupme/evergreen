module Evergreen
  class Server
    attr_reader :suite

    def serve
      server.boot
      Launchy.open(server.url(Evergreen.mounted_at.to_s + '/'))
      puts "Starting server at 127.0.0.1:#{server.port}"
      trap("INT"){ @kill = true }
      while !@kill do
        sleep 1
      end
    end

  protected

    def server
      @server ||= Capybara::Server.new(Evergreen.application)
    end
  end
end
