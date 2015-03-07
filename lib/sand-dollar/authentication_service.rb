module SandDollar::AuthenticationService
  module_function

  def authenticate_request(request)
    authenticators = [:token, :password]

    authenticators.select {|key|
      auth = SandDollar::Authenticators.load(key).new(request)
      auth.valid?
    }.map{|key|
      auth = SandDollar::Authenticators.load(key).new(request)
      identity = auth.authenticate!
      identity.is_a?(SandDollar.configuration.user_model_class) ? identity : nil
    }.compact.first
  end

  def authenticate_request!(*args)
    authenticate_request(*args) or raise SandDollar::AuthenticationFailed
  end

end
