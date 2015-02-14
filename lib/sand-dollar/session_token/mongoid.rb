module SandDollar::SessionToken
  module Mongoid

    def self.included(base)
      base.class_eval do
        base.extend ClassMethods
        base.include InstanceMethods

        ##############################
        ## INDEXES                  ##
        ##############################

        index({ token: 1 }, { unique: true, name: "sand_dollar_token_index" })
        index({ updated_at: 1 }, { expire_after_seconds: session_lifetime })

        ##############################
        ## RELATIONSHIPS            ##
        ##############################

        belongs_to :user, inverse_of: nil

        ##############################
        ## FIELDS                   ##
        ##############################

        field :token, type: String
        attr_readonly :token

        ##############################
        ## SCOPES                   ##
        ##############################

        scope :alive, -> () {
          all_of(
            {"updated_at" => {'$gte' => Time.now - session_lifetime}}
          )
        }
      end
    end


    ##############################
    ## CLASS METHODS            ##
    ##############################

    module ClassMethods
      def find_by_token(token, scope = unscoped)
        scope.where(token: token).first rescue nil
      end
    end

    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    module InstanceMethods

      def after_initialize(*args)
        set_token
      end

      def keep_alive
        self.touch
      end

      protected

      def set_token
        self.token = generate_token
      end
    end

  end

end
