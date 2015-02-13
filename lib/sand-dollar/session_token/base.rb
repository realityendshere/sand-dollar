module SandDollar::SessionToken
  module Base

    def self.included(base)
      base.class_eval do
        base.extend ClassMethods
      end
    end


    ##############################
    ## CLASS METHODS            ##
    ##############################

    module ClassMethods
      def session_lifetime
        SandDollar.configuration.session_lifetime
      end
    end


    ##############################
    ## ATTR ACCESSORS           ##
    ##############################

    module AttrAccessors
      def token
        @token
      end

      def updated_at
        @updated_at
      end
    end


    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    def initialize(*args)
      self.send(:before_initialize, *args) if self.respond_to?(:before_initialize)
      ret = super
      self.send(:after_initialize, *args) if self.respond_to?(:after_initialize)
      ret
    end

    def before_initialize(*args)
      nil
    end

    def after_initialize(*args)
      # Extend instance here to reduce conflicts with ActiveRecord/Mongoid
      # and potentially other libraries
      self.extend(AttrAccessors)
      set_token
    end

    def ttl
      updated_at + self.class.session_lifetime - Time.now
    end

    def expired?
      ttl < 1
    end

    def alive?
      !expired?
    end

    def keep_alive
      @updated_at = Time.now
      self
    end

    protected

    def set_token
      @token = generate_token
      @updated_at = Time.now
      self
    end

    # protected

    def generate_token
      l = SandDollar.configuration.token_length
      SecureRandom.base64(l).tr('+/=lIO0', 'pqrsxyz')[0...l]
    end

  end

end
