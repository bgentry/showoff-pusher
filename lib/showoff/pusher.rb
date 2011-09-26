require 'showoff'
require 'pusher'
require 'uri'

class ShowOff < Sinatra::Application
  class Pusher
    def initialize(app)
      @app            = app
      @secret         = ENV['SHOWOFF_SECRET'] || 'PleaseChangeMe'
      if ENV['PUSHER_URL']
        @pusher_uri     = URI.parse(ENV['PUSHER_URL'])
        ::Pusher.app_id   = @pusher_uri.path.split('/').last
        ::Pusher.key      = @pusher_uri.user
        ::Pusher.secret   = @pusher_uri.password
      else
        log_disabled
      end
    end

    def call(env)
      req = Rack::Request.new(env)

      if ENV['PUSHER_URL']
        if req.path == '/slide'
          if req.params['sekret'] == @secret
            params = { 'slide' => req.params['num'].to_i }
            params['incr'] = req.params['incr'].to_i if req.params['incr']
            ::Pusher['presenter'].trigger('slide_change', params)
          end

          [ 204, {}, [] ]
        elsif req.path == '/javascripts/pusher.js'
          [200, {'Content-Type' => 'application/javascript'}, pusher_js]
        else
          @app.call env
        end
      else
        log_disabled
        @app.call env
      end
    end

    def log_disabled
      puts "PUSHER_URL is not defined. ShowOff::Pusher is disabled."
    end

    def pusher_js
      @template ||= File.read(File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'views', 'pusher.js.erb')))
      ERB.new(@template).result
    end

    def self.socket
      @pusher_socket  ||= URI.parse(ENV['PUSHER_SOCKET_URL']).path.split('/').last
    rescue
      puts "Invalid PUSHER_SOCKET_URL"
      ''
    end
  end
end
