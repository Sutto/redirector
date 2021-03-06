require 'uri'

module Redirector
  class Controller

    # Configuration has some options:

    attr_accessor :destination_uri, # Target for the syncing...
                  :manifest_path,   # Where can we find out manifest?
                  :log_path,        # If present, where do we log? (STDOUT, by default)
                  :dry_run          # Is this a dry run?

    def initialize(options = {})
      @dry_run = false
      @log_path = nil
      @destination_uri = nil
      @manifest_path = nil
    end

    def unpack_options(options)
      @dry_run = !!options[:dry_run] if options.key?(:dry_run)

      @manifest_path   = options.fetch(:manifest_path) if options.key?(:manifest_path)
      @log_path        = options.fetch(:log_path) if options.key?(:log_path)
      @destination_uri = options.fetch(:destination_uri) if options.key?(:destination_uri)
    end

    def validate
      raise ArgumentError.new("Manifest path does not exist") unless manifest_path && ::File.exist?(manifest_path)
      raise ArgumentError.new("Destination URI Invalid") unless destination_uri && ::URI.parse(destination_uri).present? 
      # Otherwise fine here...
    end

    def invoke!
      logger = create_logger
      manifest = create_manifest
      destination = create_destination

      syncer = Destination::Syncer.new(manifest, destination, logger)
      syncer.run dry_run
    end

    protected

    def create_logger
      ::Logger.new(log_path || STDOUT)
    end

    def create_destination
      parsed_uri = URI.parse(destination_uri)
      case parsed_uri.scheme
      when "s3"
      when "nop"
        # Mock / NOOP destination....
        Redirector::Destination.new
      else
        raise ArgumentError.new("We do not support #{parsed_uri.scheme} as a known URI scheme.")
      end
    end

    def create_manifest
      Redirector::Manifest.load_file! manifest_path
    end


  end
end