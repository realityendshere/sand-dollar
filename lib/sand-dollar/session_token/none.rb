module SandDollar::SessionToken
  module None

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

    end

    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    module InstanceMethods

    end

  end

end
