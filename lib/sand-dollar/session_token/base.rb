module SandDollar::SessionToken
  module Base
    TTL = SandDollar.configuration.session_lifetime

    # def self.included(base)
    #   base.class_eval do
    #     attr_reader :token
    #   end
    # end

    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    # def initialize(params = {})
    #   set_token
    # end

    def ttl
      updated_at + TTL - Time.now
    end

    def expired?
      ttl < 1
    end

    def alive?
      !expired?
    end

    protected

    def set_token
      @token = generate_token
    end

    # protected

    def generate_token
      l = SandDollar.configuration.token_length
      SecureRandom.base64(l).tr('+/=lIO0', 'pqrsxyz')[0...l]
    end

  end

end
