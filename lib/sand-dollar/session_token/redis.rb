require 'redis'

module SandDollar::Models::SessionToken
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
        keys = store.keys("#{storage_key_for(token)}/*")
        keys && keys.count > 0
      end

      def discard(token)
        keys = store.keys("#{storage_key_for(token)}/*")
        store.del(*keys) if keys && keys.count > 0
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
        @updated_at ||= _retrieve_updated_at
      end

      def identify_user
        @identity ||= _retrieve_identity
      end

      def authenticated_as user_instance
        @identity = user_instance.respond_to?(:id) ? user_instance.id : user_instance
        self.save
      end

      def save
        _set_with_expire(storage_key_identity, identify_user)
        _set_with_expire(storage_key_updated_at, updated_at)
        self
      end

      def load_token(token)
        token = token.to_s.strip
        return self unless token.length > 0 && self.class.token_exists?(token)

        @updated_at = _retrieve_updated_at
        @token = token

        self
      end

      protected

      def update_activity_timestamp
        @updated_at = Time.now
        self
      end

      def store
        self.class.store
      end

      def storage_key
        self.class.storage_key_for(token)
      end

      def _set_with_expire(key, value)
        return false if value.to_s.empty?
        store.set(key, value)
        store.expire(key, ttl.ceil)
        true
      end

      def _retrieve_updated_at
        ts = store.get(storage_key_updated_at)
        Time.parse(ts) rescue nil
      end

      def _retrieve_identity
        store.get(storage_key_identity)
      end

      def storage_key_updated_at
        "#{storage_key}/updated_at"
      end

      def storage_key_identity
        "#{storage_key}/#{self.class.user_model_id_field}"
      end
    end

  end

end
