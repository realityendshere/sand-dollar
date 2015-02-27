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
          session_start
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

        def session_start
          if post_params && _provided_valid_credentials?
            current_api_session_token.authenticated_as _identity
          end
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

        def _identity
          @identity ||= current_api_session_token.user_model_class.find_by_identification(_identification)
        end

        def _identification
          post_params[:identification]
        end

        def _password
          post_params[:password]
        end

        def _provided_valid_credentials?
          SandDollar::AuthenticationService.valid_identification_provided!(_identification) && _provided_valid_password?
        end

        def _provided_valid_password?
          SandDollar::AuthenticationService.authenticate_with_password!(_identity, _password.to_s)
        end

      end

    end
  end
end
