module SandDollar::SessionToken
  module None

    def self.included(base)
      base.class_eval do
        # base.extend ClassMethods
        base.include InstanceMethods
      end
    end


    # ##############################
    # ## CLASS METHODS            ##
    # ##############################

    # module ClassMethods

    # end

    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    module InstanceMethods
      def load_token(token)
        token = token.to_s.strip
        return self unless token.length > 0 && self.class.store.has_key?(token)

        @token = token
        self
      end
    end

  end

end
