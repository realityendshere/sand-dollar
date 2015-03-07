# TODO: figure out how to (best) load and use custom authenticators
#       from the Rails App/API

class SandDollarPasswordAuthenticator < SandDollar::Authenticators::Base
  # def valid?
  #   return false unless request.post?
  #   !(post_params[:identification].blank? || post_params[:password].blank?)
  # end

  def authenticate!
    user = user_model_class.find_by_identification(identification)
    if user.nil? || user.password != season_password(password, user.password_salt)
      false
    else
      user
    end
  end

  def post_params
    request.params.fetch('session')
  end

  def identification
    post_params['identification']
  end

  def password
    post_params['password']
  end

end
