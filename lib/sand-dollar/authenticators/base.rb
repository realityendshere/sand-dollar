module SandDollar
  module Authenticators
    class Base

      attr_reader :request, :token_class, :user_class

      def initialize(options = {request: nil, token_class: nil, user_class: nil})
        self.request = options[:request]
        self.token_class = options[:token_class]
        self.user_class = options[:user_class]
      end

      private

      def request=(value)
        throw SandDollar::InvalidRequest unless value.is_a?(Rack::Request)
        @request = value
      end

      def token_class=(value)
        @token_class = value
      end

      def user_class=(value)
        @user_class = value || SandDollar.configuration.user_model_class
      end

      def user_model_class
        user_class
      end

      def season_password(*args)
        SandDollar::Utilities.season_password(*args)
      end

    end
  end
end
