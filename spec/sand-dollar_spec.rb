require 'spec_helper'

describe SandDollar::Configuration do
  describe "default config" do
    it "has a session_lifetime of 1200" do
      expect(SandDollar.configuration.session_lifetime).to eq(1200)
    end

    it "has a token_length of 128" do
      expect(SandDollar.configuration.token_length).to eq(128)
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
      expect(SandDollar.configuration.session_lifetime).to eq(1200)
    end

    it "configures the token_length" do
      expect(SandDollar.configuration.token_length).to eq(128)
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
