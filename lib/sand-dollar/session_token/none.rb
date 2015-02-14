module SandDollar::SessionToken
  module None

    def self.included(base)
      base.class_eval do
        # base.extend ClassMethods
        base.include InstanceMethods
      end
    end


    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    module InstanceMethods
      def token
        @token
      end

      def updated_at
        @updated_at
      end

      def after_initialize(*args)
        set_token
      end
    end

  end

end
