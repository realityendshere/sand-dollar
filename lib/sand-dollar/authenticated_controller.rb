module SandDollar::AuthenticatedController

  def self.included(base)
    base.class_eval do
      skip_before_action :verify_authenticity_token
      rescue_from AuthenticationService::NotAuthorized, with: :_not_authorized
      rescue_from AuthenticationService::AuthenticationFailed, with: :_authentication_failed
      rescue_from ActionController::ParameterMissing, with: :_parameter_missing
      before_filter :api_session_token_authenticate!

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

    def session_class
      self.class.session_class
    end

    private

    def signed_in?
      !!_current_identification
    end

    def signed_in!
      return _not_authorized unless signed_in?
    end

    def current_user
      _current_user_model.find(_current_identification) rescue nil
    end

    def api_session_token_authenticate!
      return _not_authorized unless _authorization_header && current_api_session_token.alive?
      current_api_session_token.keep_alive
      nil
    end

    def current_api_session_token
      @current_api_session_token ||= (session_class.discover(_authorization_header) || session_class.dispense())
      @current_api_session_token
    end

    def _authorization_header
      session_token = request.headers['Session-Token']
      session_token unless session_token.blank?
    end

    def _parameter_missing e
      _error e.to_s, 400
    end

    def _current_identification
      current_api_session_token.send(current_api_session_token.class.token_user_id_field)
    end

    def _current_user_model
      current_api_session_token.class.token_user_class
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
