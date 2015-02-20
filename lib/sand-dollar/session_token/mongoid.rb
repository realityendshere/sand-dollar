module SandDollar::SessionToken
  module Mongoid

    def self.included(base)
      base.class_eval do
        base.extend ClassMethods
        base.include InstanceMethods

        ##############################
        ## INDEXES                  ##
        ##############################

        index({ updated_at: 1 }, { expire_after_seconds: session_lifetime })

        ##############################
        ## RELATIONSHIPS            ##
        ##############################

        belongs_to :user, inverse_of: nil

        ##############################
        ## FIELDS                   ##
        ##############################

        field :_id, type: String, default: -> { generate_token }

      end
    end


    ##############################
    ## CLASS METHODS            ##
    ##############################

    module ClassMethods
      def find_by_token(token)
        self.find(token) rescue nil
      end
    end

    ##############################
    ## INSTANCE METHODS         ##
    ##############################

    module InstanceMethods

      def token
        read_attribute(:_id)
      end

      def updated_at
        read_attribute(:updated_at)
      end

      def user_id
        read_attribute(:user_id)
      end

      def authenticate_as user_instance
        self.user = user_instance
        self.save
      end

      protected

      def setup_session
        self
      end

      def update_activity_timestamp
        self.write_attribute(:updated_at, Time.now)
        self.save
        self
      end

    end

  end

end
