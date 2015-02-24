module SandDollar::SessionController

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

    private

    def post_params
      params.require(:session).permit(:identification, :password)
    end

    def _user
      @user ||= User.find_by_username(_identification)
    end

    def _identification
      post_params[:identification]
    end

    def _password
      post_params[:password]
    end

    def _provided_valid_credentials?
      AuthenticationService.valid_identification_provided!(_identification) && _provided_valid_password?
    end

    def _provided_valid_password?
      AuthenticationService.authenticate_with_password!(_user, _password.to_s)
    end

    def _provided_valid_api_key?
      params[:api_key] == 'foo key'
    end

  end

end
