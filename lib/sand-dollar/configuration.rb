module SandDollar
  class Configuration
    attr_reader :session_lifetime,
                :token_length

    def initialize
      # Number of seconds of inactivity a session will survive
      self.session_lifetime = 1200

      # Number of seconds of inactivity a session will survive
      self.token_length = 128
    end

    def session_lifetime=(int)
      unless int.is_a? Integer
        warn "SandDollar session_lifetime must be an Integer, #{int.class} provided. Using current value: #{@session_lifetime}"
        return
      end

      @session_lifetime = int
    end

    def token_length=(int)
      unless int.is_a? Integer
        warn "SandDollar token_length must be an Integer, #{int.class} provided. Using current value: #{@token_length}"
        return
      end

      @token_length = int
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
