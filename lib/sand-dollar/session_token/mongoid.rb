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

        belongs_to token_user_model_config, inverse_of: nil

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
      def discard(token)
        record = discover(token)
        record.delete if record.respond_to?(:delete)
      end

      def discard_all
        self.all.map!(&:discard)
      end

      def discover(token)
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

      def authenticate_as user_instance
        write_attribute(self.class.token_user_id_field, user_instance.id)
        self.save
      end

      def identify_user
        read_attribute(self.class.token_user_id_field)
      end

      def discard
        self.delete
      end

      protected

      def setup_session
        self
      end

      def update_activity_timestamp
        self.write_attribute(:updated_at, Time.now)
        self
      end

    end

  end

end
