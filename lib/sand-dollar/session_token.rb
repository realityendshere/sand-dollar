module SandDollar::SessionToken

  def self.included(base)
    base.class_eval do
      base.extend ClassMethods
      base.include InstanceMethods

      persistence_strategy = SandDollar.configuration.storage

      require "sand-dollar/session_token/#{persistence_strategy}"
      include_module = const_get(persistence_strategy.capitalize)

      base.include include_module
    end
  end


  ##############################
  ## CLASS METHODS            ##
  ##############################

  module ClassMethods
    def store
      @store ||= Hash.new
    end

    def dispense(*args)
      self.new(*args)
    end

    def discard(token)
      store.delete(token)
    end

    def discard_all
      @store = nil
    end

    def token_exists?(token)
      token = token.to_s.strip
      return false unless token.length > 0
      store.has_key?(token)
    end

    def discover(token)
      return nil unless token_exists?(token)
      new().load_token(token)
    end

    def session_lifetime
      SandDollar.configuration.session_lifetime
    end

    def token_user_class
      token_user_class_name.constantize
    end

    def token_user_id_field
      token_user_class_name.foreign_key.to_sym
    end

    def token_user_class_name
      token_user_model_config.to_s.classify
    end

    def token_user_model_config
      SandDollar.configuration.user_model
    end
  end

  ##############################
  ## INSTANCE METHODS         ##
  ##############################

  module InstanceMethods
    def initialize(*args)
      self.send(:before_initialize, *args) if self.respond_to?(:before_initialize)
      define_singleton_method(self.class.token_user_id_field, method(:identify_user))
      ret = super
      self.send(:after_initialize, *args) if self.respond_to?(:after_initialize)
      ret
    end

    def before_initialize(*args)
      nil
    end

    def after_initialize(*args)
      setup_session
    end

    def token
      @token ||= generate_token
    end

    def updated_at
      session_data[:updated_at]
    end

    def ttl
      return 0 unless updated_at
      updated_at + self.class.session_lifetime - Time.now
    end

    def expired?
      ttl <= 0
    end

    def alive?
      !expired?
    end

    def keep_alive
      return self if expired?
      update_activity_timestamp.save
      self
    end

    def save
      defined?(super) ? super : false
    end

    def discard
      self.class.discard(token)
    end

    def authenticated_as user_instance
      session_data[self.class.token_user_id_field] = user_instance.respond_to?(:id) ? user_instance.id : user_instance
    end

    def identify_user
      session_data[self.class.token_user_id_field]
    end

    def load_token(token)
      self
    end

    protected

    def setup_session
      update_activity_timestamp
    end

    def update_activity_timestamp
      session_data[:updated_at] = Time.now
      self
    end

    def generate_token
      l = SandDollar.configuration.token_length
      SecureRandom.base64(l).tr('+/=lIO0', 'pqrsxyz')[0...l]
    end

    def session_data
      self.class.store[token] ||= {}
    end
  end
end
