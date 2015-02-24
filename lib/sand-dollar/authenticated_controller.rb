module SandDollar::AuthenticatedController

  def self.included(base)
    base.class_eval do
      skip_before_action :verify_authenticity_token
      rescue_from AuthenticationService::NotAuthorized, with: :_not_authorized
      rescue_from AuthenticationService::AuthenticationFailed, with: :_authentication_failed
      rescue_from ActionController::ParameterMissing, with: :_parameter_missing
      before_filter :api_session_token_authenticate!

      base.include InstanceMethods
    end
  end

  ##############################
  ## INSTANCE METHODS         ##
  ##############################

  module InstanceMethods

    private

    def signed_in?
      !!current_api_session_token.user_id
    end

    def signed_in!
      return _not_authorized unless signed_in?
    end

    def current_user
      User.find(current_api_session_token.user_id) rescue nil
    end

    def api_session_token_authenticate!
      return _not_authorized unless _authorization_header && current_api_session_token.alive?
      current_api_session_token.keep_alive
      nil
    end

    def current_api_session_token
      @current_api_session_token ||= (APISessionToken.discover(_authorization_header) || APISessionToken.dispense())
      @current_api_session_token
    end

    def _authorization_header
      session_token = request.headers['Session-Token']
      session_token unless session_token.blank?
    end

    def _parameter_missing e
      _error e.to_s, 400
    end

    def _bad_request message = "Bad request"
      _error message, 400
    end

    def _not_authorized message = "Not Authorized"
      current_api_session_token.discard
      _error message, 401
    end

    def _authentication_failed
      _not_authorized "I am sure it was just a typo. The provided username and password didn't work."
    end

    def _not_found message = "Not Found"
      _error message, 404
    end

    def _error message, status
      render json: { error: message }, status: status
    end

  end

end
