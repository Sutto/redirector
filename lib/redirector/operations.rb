module Redirector
  module Operations

    class RedirectOperation

      attr_reader :redirect

      def initialize(redirect)
        @redirect =  redirect
      end

      def summarize
        "#{self.class.name} on #{redirect}"
      end

    end

    class RemoveRedirect < RedirectOperation; end
    class UpdateDestination < RedirectOperation; end
    class CreateRedirect < RedirectOperation; end

  end
end