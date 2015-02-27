module SandDollar
  module Authenticators
    class Base

      attr_reader :request

      def initialize(request)
        throw SandDollar::InvalidRequest unless request.is_a?(Rack::Request)
        @request = request
      end

      private

      def user_model_class
        SandDollar.configuration.user_model_class
      end

      def season_password
        SandDollar::Utilities.season_password
      end

    end
  end
end