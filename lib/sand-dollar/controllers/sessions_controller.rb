module SandDollar
  module Controllers
    module SessionsController

      def self.included(base)
        base.class_eval do
          skip_before_filter :api_session_token_authenticate!, only: [:create]
          base.include InstanceMethods
        end
      end

      ##############################
      ## INSTANCE METHODS         ##
      ##############################

      module InstanceMethods

        def create
          activate_current_api_session_token if post_params && authenticate!
          render request.format.to_sym => {session: session_token_hash}, :status => 201
        end

        def show
          render request.format.to_sym => {session: session_token_hash}
        end

        def destroy
          current_api_session_token.discard
          render nothing: true, status: 204
        end

        private

        def activate_current_api_session_token
          current_api_session_token.authenticated_as @current_user
        end

        def session_token_hash
          hash = Hash.new
          id_field = current_api_session_token.user_model_id_field

          hash[:token] = current_api_session_token.token
          hash[:ttl] = current_api_session_token.ttl
          hash[id_field] = current_api_session_token.send(id_field)

          hash
        end

        def post_params
          params.require(:session).permit(:identification, :password)
        end

      end

    end
  end
end
