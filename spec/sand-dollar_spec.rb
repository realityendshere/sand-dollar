require 'spec_helper'

describe SandDollar::Configuration do
  describe "default config" do
    it "has a session_lifetime of #{SandDollar::Default::SESSION_LIFETIME}" do
      expect(SandDollar.configuration.session_lifetime).to eq(SandDollar::Default::SESSION_LIFETIME)
    end

    it "has a token_length of #{SandDollar::Default::TOKEN_LENGTH}" do
      expect(SandDollar.configuration.token_length).to eq(SandDollar::Default::TOKEN_LENGTH)
    end

    it "has a storage of #{SandDollar::Default::STORAGE}" do
      expect(SandDollar.configuration.storage).to eq(SandDollar::Default::STORAGE)
    end

    it "has a user_model of #{SandDollar::Default::USER_MODEL}" do
      expect(SandDollar.configuration.user_model).to eq(SandDollar::Default::USER_MODEL)
    end
  end

  describe "invalid config" do
    after do
      SandDollar.reset_configuration
    end

    describe "for session_lifetime" do
      before do
        SandDollar.configure do |config|
          config.session_lifetime = session_lifetime
        end
      end

      context "when provided a String for session_lifetime" do
        let(:session_lifetime) { 'Batman' }

        it "uses the default session_lifetime" do
          expect(SandDollar.configuration.session_lifetime).to eq(SandDollar::Default::SESSION_LIFETIME)
        end
      end

      context "when provided nil for session_lifetime" do
        let(:session_lifetime) { nil }

        it "uses the default session_lifetime" do
          expect(SandDollar.configuration.session_lifetime).to eq(SandDollar::Default::SESSION_LIFETIME)
        end
      end

      context "when provided 0 for session_lifetime" do
        let(:session_lifetime) { 0 }

        it "uses the default session_lifetime" do
          expect(SandDollar.configuration.session_lifetime).to eq(SandDollar::Default::SESSION_LIFETIME)
        end
      end

      context "when provided a negative integer for session_lifetime" do
        let(:session_lifetime) { -10 }

        it "uses the default session_lifetime" do
          expect(SandDollar.configuration.session_lifetime).to eq(SandDollar::Default::SESSION_LIFETIME)
        end
      end

    end


    context "when provided an invalid token_length" do
      before do
        SandDollar.configure do |config|
          config.token_length = 'Robin'
        end
      end

      it "uses the default token_length" do
        expect(SandDollar.configuration.token_length).to eq(SandDollar::Default::TOKEN_LENGTH)
      end
    end

    context "when provided an invalid user_model" do
      before do
        SandDollar.configure do |config|
          config.user_model = '             '
        end
      end

      it "uses the default user_model" do
        expect(SandDollar.configuration.user_model).to eq(SandDollar::Default::USER_MODEL)
      end
    end

    context "when provided an invalid storage strategy" do
      it "raises an exception" do
        expect {
          SandDollar.configure do |config|
            config.storage = :foobar
          end
        }.to raise_error SandDollar::InvalidStorageConfig
      end
    end

  end

  describe "#configure" do
    after do
      SandDollar.reset_configuration
    end

    context "when provided a valid config" do

      before do
        SandDollar.configure do |config|
          config.session_lifetime = session_lifetime
          config.token_length = token_length
          config.user_model = user_model
          config.storage = storage
        end
      end

      let(:session_lifetime) { 180 }
      let(:token_length) { 512 }
      let(:user_model) { 'AdminUser' }
      let(:storage) { 'Mongoid' }

      it "configures the session_lifetime" do
        expect(SandDollar.configuration.session_lifetime).to eq(session_lifetime)
      end

      it "configures the token_length" do
        expect(SandDollar.configuration.token_length).to eq(token_length)
      end

      it "configures the user_model" do
        expect(SandDollar.configuration.user_model).to eq(:admin_user)
      end

      it "configures the storage" do
        expect(SandDollar.configuration.storage).to eq(:mongoid)
      end

    end

  end
end
