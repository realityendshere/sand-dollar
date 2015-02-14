module SandDollar::SessionToken

  def self.included(base)
    base.class_eval do
      base.extend ClassMethods

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
    def session_lifetime
      SandDollar.configuration.session_lifetime
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
    nil
  end

  def ttl
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
