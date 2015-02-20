require 'redis'

module SandDollar::SessionToken
  module Redis

    # TODO: Make this work.
    # Use http://resistor.io/blog/2013/08/07/mimimal-api-authentication-on-rails/
    # For inspiration
    def self.included(base)
      base.class_eval do
        base.extend ClassMethods
        base.include InstanceMethods
      end
    end


    ##############################
    ## CLASS METHODS            ##
    ##############################

    module ClassMethods
      def store
        @store ||= ::Redis.new
      end

      def find_by_token(token)
        new().load_token(token)
      end
    end

    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    module InstanceMethods

      def updated_at
        session_data[:updated_at]
      end

      def user_id
        session_data[:user_id]
      end

      def authenticate_as user_instance
        session_data[:user_id] = user_instance.respond_to?(:id) ? user_instance.id : user_instance
        self.save
      end

      def save
        store.set(token, session_data.to_json)
        store.expire(token, ttl.ceil)
        self
      end

      def load_token(token)
        token = token.to_s.strip
        return self unless token.length > 0

        result = store.get(token)
        return self unless result.is_a?(String)

        @session_data = JSON.parse(result, :symbolize_names => true)
        @session_data[:updated_at] = DateTime.parse(@session_data[:updated_at]).to_time
        @token = token
        self
      end

      protected

      def update_activity_timestamp
        session_data[:updated_at] = Time.now
        self.save
        self
      end

      def store
        self.class.store
      end

      def session_data
        @session_data ||= {}
      end
    end

  end

end
