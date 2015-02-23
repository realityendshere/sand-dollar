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

      def token_exists?(token)
        token = token.to_s.strip
        return false unless token.length > 0
        store.exists(storage_key_for(token))
      end

      def discard(token)
        store.del(storage_key_for(token))
      end

      def discard_all
        keys = store.keys("#{storage_key_prefix}/*")
        store.del(*keys) if keys && keys.count > 0
      end

      def storage_key_for(token)
        "#{storage_key_prefix}/#{token}"
      end

      def storage_key_prefix
        'token'
      end

    end

    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    module InstanceMethods

      def updated_at
        session_data[:updated_at]
      end

      def identify_user
        session_data[self.class.token_user_id_field]
      end

      def authenticate_as user_instance
        session_data[self.class.token_user_id_field] = user_instance.respond_to?(:id) ? user_instance.id : user_instance
        self.save
      end

      def save
        _set_with_expire(self.class.storage_key_for(token), session_data.to_json)
        self
      end

      def load_token(token)
        token = token.to_s.strip
        return self unless token.length > 0 && store.exists(self.class.storage_key_for(token))

        result = store.get(self.class.storage_key_for(token))
        return self unless result.is_a?(String)

        @token = token
        @session_data = JSON.parse(result, :symbolize_names => true)
        @session_data[:updated_at] = Time.parse(@session_data[:updated_at])

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

      def storage_key
        self.class.storage_key_for(token)
      end

      def _set_with_expire(key, value)
        return false if value.to_s.empty? || expired?
        store.set(key, value)
        store.expire(key, ttl.ceil)
        true
      end
    end

  end

end
