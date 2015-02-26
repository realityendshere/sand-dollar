module SandDollar
  module Controllers
    module AuthorizedController

      def self.included(base)
        base.class_eval do
          before_filter :signed_in!
        end
      end

      ##############################
      ## INSTANCE METHODS         ##
      ##############################

      # module InstanceMethods
      # end

    end
  end
end
