require 'thread'

module Redirector
  class Applicator

    attr_reader :destination, :logger, :logger_mutex

    def initialize(destination, logger)
      @destination = destination
      @logger = logger
      @logger_mutex = Mutex.new
    end

    def apply(operation)
      case operation
      when Redirector::Operations::RemoveRedirect
        # Remove the given item...
        destination.remove_key operation.redirect.path
      when Redirector::Operations::CreateRedirect, Redirector::Operations::UpdateRedirect
        rendered = Redirector::Renderer.new('redirect.erb').render(url: operation.redirect.url)
        destination.put_key operation.redirect.path, operation.redirect.url, rendered
      end
      logger_mutex.synchronize { logger.info "=> Applied #{operation.summarize}" }
    end

  end
end