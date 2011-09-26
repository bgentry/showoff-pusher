require 'showoff'
require 'pusher'
require 'uri'

class ShowOff
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
      <<-JS
        var setupPusher = function(){
          var presenter = /presenter=([^&]*)/.exec(window.location.search),
              sekret    = presenter && presenter[1];

          if (sekret) {
            $(function() {
              $('body').bind('showoff:show', function(e) {
                console.debug("EVENT: " + slidenum);
                $.post('/slide', { sekret: sekret, num: slidenum });
              });
              $('body').bind('showoff:incr', function(e) {
                console.debug("INCREMENT: " + e.slidenum + ' ' + e.incr);
                $.post('/slide', { sekret: sekret, num: slidenum, incr: e.incr });
              });
            });

          } else {

            // Enable pusher logging - don't include this in production
            Pusher.log = function(message) {
              if (window.console && window.console.log) window.console.log(message);
            };

            new Pusher('#{ShowOff::Pusher.socket}')
              .subscribe('presenter')
              .bind('slide_change', function(data) {
                Pusher.log('slide_change', data.slide);
                if (data.slide != slidenum){
                  gotoSlide(data.slide);
                }
                if (data.incr) {
                  while(incrCurr <= data.incr) {
                    showIncremental(incrCurr);
                    incrCurr++;
                  }
                }
              });
          }
        }
        var checkForPusher = function() {
          setTimeout(function(){
            if (typeof Pusher != 'undefined') {
              setupPusher();
            } else {
              checkForPusher()
            }
          }, 250);
        }
        checkForPusher();
      JS
    end

    def self.socket
      @pusher_socket  ||= URI.parse(ENV['PUSHER_SOCKET_URL']).path.split('/').last
    rescue
      puts "Invalid PUSHER_SOCKET_URL"
      ''
    end
  end
end
