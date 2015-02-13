module SandDollar::SessionToken
  module Ephemeral
    TTL = SandDollar.configuration.session_lifetime

    def self.included(base)
      base.class_eval do
        include SandDollar::SessionToken::Base
        attr_reader :token
      end
    end

    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    def initialize
      set_token
    end

  end

end
