# TODO: figure out how to (best) load and use custom authenticators
#       from the Rails App/API

class SandDollarTokenAuthenticator < SandDollar::Authenticators::Base
  def valid?
    !(authorization_header.blank?)
  end

  def authenticate!
    # TODO: Make this respect controller configuration for Token model
    token = (APISessionToken.discover(authorization_header) || APISessionToken.dispense())
    return false unless token.alive?

    user = user_model_class.find(token.send(token.user_model_id_field)) rescue nil
    user.nil? ? false : user
  end

  def authorization_header
    session_token = request.headers['Session-Token']
    session_token unless session_token.to_s.empty?
  end

end
