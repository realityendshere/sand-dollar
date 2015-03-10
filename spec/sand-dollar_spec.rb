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

  describe "#configure" do
    after do
      SandDollar.reset_configuration
    end

    describe "session_lifetime" do
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

      context "when provided a Symbol for session_lifetime" do
        let(:session_lifetime) { :foobar }

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

      context "when provided a valid session_lifetime" do
        let(:session_lifetime) { 180 }

        it "uses the provided session_lifetime" do
          expect(SandDollar.configuration.session_lifetime).to eq(session_lifetime)
        end
      end

    end

    describe "token_length" do
      before do
        SandDollar.configure do |config|
          config.token_length = token_length
        end
      end

      context "when provided a String for token_length" do
        let(:token_length) { 'Superman' }

        it "uses the default token_length" do
          expect(SandDollar.configuration.token_length).to eq(SandDollar::Default::TOKEN_LENGTH)
        end
      end

      context "when provided a Symbol for token_length" do
        let(:token_length) { :punkrock }

        it "uses the default token_length" do
          expect(SandDollar.configuration.token_length).to eq(SandDollar::Default::TOKEN_LENGTH)
        end
      end

      context "when provided nil for token_length" do
        let(:token_length) { nil }

        it "uses the default token_length" do
          expect(SandDollar.configuration.token_length).to eq(SandDollar::Default::TOKEN_LENGTH)
        end
      end

      context "when provided 0 for token_length" do
        let(:token_length) { 0 }

        it "uses the default token_length" do
          expect(SandDollar.configuration.token_length).to eq(SandDollar::Default::TOKEN_LENGTH)
        end
      end

      context "when provided a negative integer for token_length" do
        let(:token_length) { -10 }

        it "uses the default token_length" do
          expect(SandDollar.configuration.token_length).to eq(SandDollar::Default::TOKEN_LENGTH)
        end
      end

      context "when provided a valid token_length" do
        let(:token_length) { 180 }

        it "uses the provided token_length" do
          expect(SandDollar.configuration.token_length).to eq(token_length)
        end
      end
    end

    describe "user_model" do
      before do
        SandDollar.configure do |config|
          config.user_model = user_model
        end
      end

      context "when provided an empty String for user_model" do
        let(:user_model) { '      ' }

        it "uses the default user_model" do
          expect(SandDollar.configuration.user_model).to eq(SandDollar::Default::USER_MODEL)
        end
      end

      context "when provided nil for user_model" do
        let(:user_model) { nil }

        it "uses the default user_model" do
          expect(SandDollar.configuration.user_model).to eq(SandDollar::Default::USER_MODEL)
        end
      end

      context "when provided an Integer for user_model" do
        let(:user_model) { 100 }

        it "uses the default user_model" do
          expect(SandDollar.configuration.user_model).to eq(SandDollar::Default::USER_MODEL)
        end
      end

      context "when provided a String for user_model" do
        let(:user_model) { 'Author' }

        it "uses a symbol equivalent of the provided user_model" do
          expect(SandDollar.configuration.user_model).to eq(:author)
        end
      end

      context "when provided a Symbol for user_model" do
        let(:user_model) { :admin_user }

        it "uses the provided user_model" do
          expect(SandDollar.configuration.user_model).to eq(user_model)
        end
      end
    end

    describe "storage" do
      context "when provided an invalid storage strategy" do
        it "raises an exception" do
          expect {
            SandDollar.configure do |config|
              config.storage = :foobar
            end
          }.to raise_error SandDollar::InvalidStorageConfig
        end
      end

      context "when provided a valid storage strategy" do
        it "uses a symbol equivalent of the provided storage strategy" do
          SandDollar.configure do |config|
            config.storage = 'Mongoid'
          end

          expect(SandDollar.configuration.storage).to eq(:mongoid)
        end
      end

    end

    describe "default_authenticators" do
      before do
        SandDollar.configure do |config|
          config.default_authenticators = default_authenticators
        end
      end

      context "when provided an invalid array" do
        let(:default_authenticators) {[]}

        it "uses the provided authenticators" do
          expect(SandDollar.configuration.default_authenticators).to match_array(SandDollar::Default::AUTHENTICATORS)
        end
      end

      context "when provided a single authenticator" do
        let(:default_authenticators) {'app_token'}

        it "places the value into an array" do
          expect(SandDollar.configuration.default_authenticators).to match_array(['app_token'])
        end
      end

      context "when provided an array of authenticators" do
        let(:default_authenticators) {[:app_token, :ldap]}

        it "uses the provided configuration" do
          expect(SandDollar.configuration.default_authenticators).to match_array(default_authenticators)
        end
      end

    end

  end

end
