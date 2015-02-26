module SandDollar
  class Configuration
    attr_reader :session_lifetime,
                :token_length,
                :storage,
                :user_model

    def initialize
      # Number of seconds of inactivity a session will survive
      self.session_lifetime = SandDollar::Default::SESSION_LIFETIME

      # Number of seconds of inactivity a session will survive
      self.token_length = SandDollar::Default::TOKEN_LENGTH

      # Persistence strategy [:none, :mongoid]
      self.storage = SandDollar::Default::STORAGE

      # Name of Model to represent authenticatable users
      self.user_model = SandDollar::Default::USER_MODEL
    end

    def session_lifetime=(int)
      return if int.nil?

      unless int.is_a?(Integer) and int > 0
        warn "SandDollar session_lifetime must be an Integer, #{int.class} provided. Using current value: #{@session_lifetime}"
        return
      end

      @session_lifetime = int
    end

    def token_length=(int)
      return if int.nil?

      unless int.is_a?(Integer) and int > 0
        warn "SandDollar token_length must be an Integer, #{int.class} provided. Using current value: #{@token_length}"
        return
      end

      @token_length = int
    end

    def storage=(value)
      return if value.nil?

      value = value.to_s.underscore.to_sym

      unless SandDollar::Default::VALID_STORAGE.include?(value)
        raise SandDollar::InvalidStorageConfig
        return
      end

      @storage = value
    end

    def user_model=(value)
      return if value.nil?

      cleaned = value.to_s.underscore.strip

      unless (value.is_a?(String) || value.is_a?(Symbol))
        warn "SandDollar user_model must be a String or Symbol, #{value.class} provided. Using current value: #{@user_model}"
        return
      end

      unless cleaned.length > 0
        warn "SandDollar user_model cannot be blank. Using current value: #{@user_model}"
        return
      end

      @user_model = cleaned.to_sym
    end

    def user_model_class
      user_model_class_name.constantize
    end

    def user_model_id_field
      user_model_class_name.foreign_key.to_sym
    end

    def user_model_class_name
      user_model.to_s.classify
    end

  end

  class << self
    attr_accessor :configuration
  end

  @configuration ||= Configuration.new

  def self.configure
    yield(@configuration)
  end

  def self.reset_configuration
    @configuration = Configuration.new
  end
end
