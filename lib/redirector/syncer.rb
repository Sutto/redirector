require 'logger'
require 'concurrent'

module Redirector
  class Syncer

    attr_reader :manifest, :destination

    def initialize(manifest, destination, logger = ::Logger.new(STDOUT))
      @manifest = manifest
      @destination = destination
    end

    def run(dry_run = false)
      operations = calculate_operations

      if operations.empty?
        logger.info "Nothing to do, bailing."
        return
      end

      debug_operations operations

      if !dry_run
        apply_operations operations
      end

    end

    def calculate_operations
      contents = destination.list
      targets  = manifest.redirects

      removed = (contents.keys - targets.keys).map { |k| contents[k] }
      added   = (targets.keys - contents.keys).map { |k| targets[k] }
      changed = (targets.keys & contents.keys).select { |k| targets[k] != contents[k] }.map { |k| targets[k] }
    end

    def apply_operations(operations)
      logger_mutex = Mutex.new
      pool = Concurrent::ThreadPoolExecutor.new min_threads: 1, max_threads: 8, max_queue: 0

      applicator = Redirector::Applicator.new(destination, logger)
      operations.each do |operation|
        pool.post { applicator.apply(operation) }
      end

      pool.shutdown
      pool.wait_for_termination
    end

    def debug_operations(operations)
      logger.info "Applying #{operations.size} operations:"
      operations.each do |op|
        logger.info "=> #{op.summarize}"
      end
    end

  end
end