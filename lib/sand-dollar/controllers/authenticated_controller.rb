module SandDollar
  module Controllers
    module AuthenticatedController

      def self.included(base)
        base.class_eval do
          rescue_from SandDollar::NotAuthorized, with: :_not_authorized
          rescue_from SandDollar::AuthenticationFailed, with: :_authentication_failed
          rescue_from ActionController::ParameterMissing, with: :_parameter_missing
          before_filter :api_session_token_authenticate!, :except => [:_authentication_failed, :_not_authorized]

          base.extend ClassMethods
          base.include InstanceMethods
        end
      end

      ##############################
      ## CLASS METHODS            ##
      ##############################

      module ClassMethods
        def session_class session_class = nil
          @session_class = session_class unless session_class.nil?
          @session_class
        end

        def inherited(subclass)
          subclass.instance_variable_set('@session_class', instance_variable_get('@session_class'))
        end
      end

      ##############################
      ## INSTANCE METHODS         ##
      ##############################

      module InstanceMethods

        private

        def signed_in?
          !!current_user
        end

        def signed_in!
          signed_in? or raise SandDollar::NotAuthorized
        end

        def current_user
          @current_user ||= authenticate!
        end

        def api_session_token_authenticate!
          unless authenticate!
            raise SandDollar::NotAuthorized
          end
          current_api_session_token.keep_alive
          nil
        end

        def current_api_session_token
          @current_api_session_token ||= (session_class.discover(_authorization_header) || session_class.dispense())
          @current_api_session_token
        end

        def session_class
          self.class.session_class
        end

        def authenticate!
          @current_user = SandDollar::AuthenticationService.authenticate_request!({
            request: request,
            token_class: session_class
          })
        end

        def _authorization_header
          session_token = request.headers['Session-Token']
          session_token unless session_token.to_s.empty?
        end

        def _parameter_missing e
          _error e.to_s, 400
        end

        def _authentication_failed
          _not_authorized(I18n.t('authentication.failed.password') || "That username and password combination failed.")
        end

        def _bad_request message = "Bad request"
          _error message, 400
        end

        def _not_authorized message = "Not Authorized"
          current_api_session_token.discard
          _error message, 401
        end

        def _not_found message = "Not Found"
          _error message, 404
        end

        def _error message, status
          render json: { error: message }, status: status
        end

      end

    end
  end
end
