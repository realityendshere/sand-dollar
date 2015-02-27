module SandDollar
  module Authenticators

    class << self

      def add(key, authenticator = nil)
        authenticator ||= Class.new(SandDollar::Authenticators::Base)

        unless authenticator.method_defined?(:authenticate!)
          raise NoMethodError, "authenticate! is not declared in the #{key.inspect} authenticator"
        end

        base = SandDollar::Authenticators::Base
        unless authenticator.ancestors.include?(base)
          raise "#{key.inspect} is not a #{base}"
        end

        _authenticators[key] = authenticator
      end

      def [](key)
        _authenticators[key]
      end

      def clear!
        _authenticators.clear
      end

      def _authenticators
        @authenticators ||= {}
      end

    end
  end
end
