module SandDollar
  module Models
    module Authenticatable

      def self.included(base)
        base.class_eval do
          base.extend ClassMethods
          base.include InstanceMethods

          field :username,           type: Array, default: []
          field :password_encrypted, type: String, default: ""
          field :password_salt,      type: String, default: ""

          validates_presence_of :password_encrypted, on: :create
        end
      end


      ##############################
      ## CLASS METHODS            ##
      ##############################

      module ClassMethods
        def find_by_identification(username)
          where(username: username).first rescue nil
        end

        def season_password(password, salt)
          SandDollar::Utilities.season_password(password, salt)
        end
      end

      ##############################
      ## INSTANCE METHODS         ##
      ##############################

      module InstanceMethods
        def password
          @password ||= BCrypt::Password.new(password_encrypted)
        end

        def password=(password)
          pw_salt = salt
          write_attributes(
            password_salt: pw_salt,
            password_encrypted: BCrypt::Password.create(self.class.season_password(password, pw_salt))
          )
        end

        private

        def salt
          SecureRandom.base64(64).tr('+/=lIO0', 'pqrsxyz')[0..68]
        end
      end

    end
  end
end
