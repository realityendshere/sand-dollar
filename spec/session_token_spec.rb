require 'spec_helper'
require 'sand-dollar/session_token/ephemeral'

class APISessionToken
  include SandDollar::SessionToken::Ephemeral
end

describe SandDollar::SessionToken do
  describe "default session" do
    it "automatically generates a token" do
      token = APISessionToken.new()
      expect(token.token.length).to eq(128)
    end
  end

  describe "configured session" do
    before do
      SandDollar.configure do |config|
        config.token_length = 512
      end
    end

    after do
      SandDollar.reset_configuration
    end

    it "automatically generates a token of the configured length" do
      token = APISessionToken.new()
      expect(token.token.length).to eq(512)
    end
  end

end
