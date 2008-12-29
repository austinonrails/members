#--
# Copyright (c) 2004 David Heinemeier Hansson
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

# This class provides an interface for dispatching a CGI (or CGI-like) request
# to the appropriate controller and action. It also takes care of resetting
# the environment (when Dependencies.load? is true) after each request.
class Dispatcher
  class << self

    # Dispatch the given CGI request, using the given session options, and
    # emitting the output via the given output.  If you dispatch with your
    # own CGI object be sure to handle the exceptions it raises on multipart
    # requests (EOFError and ArgumentError).
    def dispatch(cgi = nil, session_options = ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS, output = $stdout)
      if cgi ||= new_cgi(output)
        request, response = ActionController::CgiRequest.new(cgi, session_options), ActionController::CgiResponse.new(cgi)
        prepare_application
        ActionController::Routing::Routes.recognize!(request).process(request, response).out(output)
      end
    rescue Object => exception
      failsafe_response(output, '500 Internal Server Error', exception) do
        ActionController::Base.process_with_exception(request, response, exception).out(output)
      end
    ensure
      # Do not give a failsafe response here.
      reset_after_dispatch
    end

    # Reset the application by clearing out loaded controllers, views, actions,
    # mailers, and so forth. This allows them to be loaded again without having
    # to restart the server (WEBrick, FastCGI, etc.).
    def reset_application!
      Dependencies.clear
      ActiveRecord::Base.reset_subclasses
      Class.remove_class(*Reloadable.reloadable_classes)
    end

    private
      # CGI.new plus exception handling.  CGI#read_multipart raises EOFError
      # if body.empty? or body.size != Content-Length and raises ArgumentError
      # if Content-Length is non-integer.
      def new_cgi(output)
        failsafe_response(output, '400 Bad Request') { CGI.new }
      end

      def prepare_application
        ActionController::Routing::Routes.reload if Dependencies.load?
        prepare_breakpoint
        require_dependency('application.rb') unless Object.const_defined?(:ApplicationController)
        ActiveRecord::Base.verify_active_connections!
      end

      def reset_after_dispatch
        reset_application! if Dependencies.load?
        Breakpoint.deactivate_drb if defined?(BREAKPOINT_SERVER_PORT)
      end

      def prepare_breakpoint
        return unless defined?(BREAKPOINT_SERVER_PORT)
        require 'breakpoint'
        Breakpoint.activate_drb("druby://localhost:#{BREAKPOINT_SERVER_PORT}", nil, !defined?(FastCGI))
        true
      rescue
        nil
      end

      # If the block raises, send status code as a last-ditch response.
      def failsafe_response(output, status, exception = nil)
        yield
      rescue Object
        begin
          output.write "Status: #{status}\r\n"
          
          if exception
            message    = exception.to_s + "\r\n" + exception.backtrace.join("\r\n")
            error_path = File.join(RAILS_ROOT, 'public', '500.html')

            if defined?(RAILS_DEFAULT_LOGGER) && !RAILS_DEFAULT_LOGGER.nil?
              RAILS_DEFAULT_LOGGER.fatal(message)

              output.write "Content-Type: text/html\r\n\r\n"

              if File.exists?(error_path)
                output.write(IO.read(error_path))
              else
                output.write("<html><body><h1>Application error (Rails)</h1></body></html>")
              end
            else
              output.write "Content-Type: text/plain\r\n\r\n"
              output.write(message)
            end
          end
        rescue Object
        end
      end
  end
end
