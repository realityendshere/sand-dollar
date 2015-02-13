module SandDollar::SessionToken
  module Mongoid
    TTL = SandDollar.configuration.session_lifetime

    def self.included(base)
      base.class_eval do
        include SandDollar::SessionToken::Base
        base.extend ClassMethods
        base.include( InstanceMethods )

        ##############################
        ## INDEXES                  ##
        ##############################

        index({ token: 1 }, { unique: true, name: "sand_dollar_token_index" })
        index({ updated_at: 1 }, { expire_after_seconds: TTL })

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
            {"updated_at" => {'$gte' => Time.now - TTL}}
          )
        }

        # ##############################
        # ## CALLBACKS                ##
        # ##############################

        before_create :set_token
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

      protected

      def set_token
        self.token = generate_token
      end
    end

  end

end
