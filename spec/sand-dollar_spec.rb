require 'spec_helper'

describe SandDollar::Configuration do
  describe "default config" do
    it "has a session_lifetime of #{SandDollar::Default::SESSION_LIFETIME}" do
      expect(SandDollar.configuration.session_lifetime).to eq(SandDollar::Default::SESSION_LIFETIME)
    end

    it "has a token_length of #{SandDollar::Default::TOKEN_LENGTH}" do
      expect(SandDollar.configuration.token_length).to eq(SandDollar::Default::TOKEN_LENGTH)
    end
  end

  describe "invalid config" do
    before do
      SandDollar.configure do |config|
        config.session_lifetime = 'Batman'
        config.token_length = 'Superman'
      end
    end

    it "configures the session_lifetime" do
      expect(SandDollar.configuration.session_lifetime).to eq(SandDollar::Default::SESSION_LIFETIME)
    end

    it "configures the token_length" do
      expect(SandDollar.configuration.token_length).to eq(SandDollar::Default::TOKEN_LENGTH)
    end
  end

  describe "#configure" do
    before do
      SandDollar.configure do |config|
        config.session_lifetime = 180
        config.token_length = 512
      end
    end

    after do
      SandDollar.reset_configuration
    end

    it "configures the session_lifetime" do
      expect(SandDollar.configuration.session_lifetime).to eq(180)
    end

    it "configures the token_length" do
      expect(SandDollar.configuration.token_length).to eq(512)
    end
  end
end
