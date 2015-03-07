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

      def load(key)
        authenticator "#{key.to_s}_authenticator"
      end

      def [](key)
        _authenticators[key]
      end

      def clear!
        _authenticators.clear
      end

      private

      def _authenticators
        @authenticators ||= {}
      end

      def _authenticator_directories
        [
          'authenticators',
          File.join(Dir.getwd, 'app', 'authenticators'),
          File.join(Dir.getwd, 'lib', 'authenticators')
        ]
      end

      def _authenticator_directory(name)
        _authenticator_directories.find {|dir|
          File.exist?(File.join(dir, name))
        }
      end

      def authenticator_directory!(*args)
        _authenticator_directory(*args) or raise SandDollar::AuthenticatorNotFound
      end

      def authenticator(name)
        authenticator_class = Object.const_get(name.to_s.classify) rescue nil
        return authenticator_class unless authenticator_class.nil?
        require("#{authenticator_directory!(name)}/#{name}")
        Object.const_get(name.to_s.classify) or raise SandDollar::AuthenticatorNotFound
      end

    end
  end
end
