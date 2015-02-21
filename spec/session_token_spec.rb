require 'spec_helper'
require 'delorean'

class APISessionToken
  include SandDollar::SessionToken
end

class User
end

class Employee
end

class Admin
end

describe SandDollar::SessionToken do
  after do
    SandDollar.reset_configuration
    Delorean.back_to_the_present
  end

  describe 'initialize' do
    context "When using default token length" do
      let(:subject) { APISessionToken.disburse() }

      it "automatically generates a token" do
        expect(subject.token.length).to eq(SandDollar::Default::TOKEN_LENGTH)
      end
    end

    context "When using configured token length" do
      before do
        SandDollar.configure do |config|
          config.token_length = 512
        end
      end

      let(:subject) { APISessionToken.disburse() }

      it "automatically generates a token of the configured length" do
        expect(subject.token.length).to eq(512)
      end
    end
  end

  describe "#disburse" do
    it "returns a new token instance" do
      subject = APISessionToken.disburse()
      expect(subject.is_a?(APISessionToken)).to eq(true)
    end
  end

  describe "#session_lifetime" do
    context "When using the default config" do
      it "returns the default session_lifetime" do
        expect(APISessionToken.session_lifetime).to eq(SandDollar::Default::SESSION_LIFETIME)
      end
    end

    context "When using a custom config" do
      before do
        SandDollar.configure do |config|
          config.session_lifetime = life
        end
      end

      let(:life) { 9000 }
      it "returns the specified session_lifetime" do
        expect(APISessionToken.session_lifetime).to eq(life)
      end
    end
  end

  describe "#token_user_model_config" do
    before do
      SandDollar.configure do |config|
        config.user_model = user_model
      end
    end

    context "When using the default config" do
      let(:user_model) { nil }
      it "returns the default user_model config" do
        expect(APISessionToken.token_user_model_config).to eq(SandDollar::Default::USER_MODEL)
      end
    end

    context "When using a symbol for user_model" do
      let(:user_model) { :employee }
      it "returns the specified user_model" do
        expect(APISessionToken.token_user_model_config).to eq(:employee)
      end
    end

    context "When using a string for user_model" do
      let(:user_model) { 'Admin' }
      it "returns the specified user_model" do
        expect(APISessionToken.token_user_model_config).to eq(:admin)
      end
    end
  end

  describe "#token_user_class_name" do
    before do
      SandDollar.configure do |config|
        config.user_model = user_model
      end
    end

    context "When using the default config" do
      let(:user_model) { nil }
      it "returns the default User class" do
        expect(APISessionToken.token_user_class_name).to eq('User')
      end
    end

    context "When using a symbol for user_model" do
      let(:user_model) { :employee }
      it "returns the specified User class" do
        expect(APISessionToken.token_user_class_name).to eq('Employee')
      end
    end

    context "When using a string for user_model" do
      let(:user_model) { 'Admin' }
      it "returns the specified User class" do
        expect(APISessionToken.token_user_class_name).to eq('Admin')
      end
    end
  end

  describe "#token_user_id_field" do
    before do
      SandDollar.configure do |config|
        config.user_model = user_model
      end
    end

    context "When using the default config" do
      let(:user_model) { nil }
      it "returns the default User ID field" do
        expect(APISessionToken.token_user_id_field).to eq(:user_id)
      end
    end

    context "When using a symbol for user_model" do
      let(:user_model) { :employee }
      it "returns the ID field for the specified User class" do
        expect(APISessionToken.token_user_id_field).to eq(:employee_id)
      end
    end

    context "When using a string for user_model" do
      let(:user_model) { 'Admin' }
      it "returns the ID field for the specified User class" do
        expect(APISessionToken.token_user_id_field).to eq(:admin_id)
      end
    end
  end

  describe "#token_user_class" do
    before do
      SandDollar.configure do |config|
        config.user_model = user_model
      end
    end

    context "When using the default config" do
      let(:user_model) { nil }
      it "returns the default User class" do
        expect(APISessionToken.token_user_class).to eq(User)
      end
    end

    context "When using a symbol for user_model" do
      let(:user_model) { :employee }
      it "returns the specified User class" do
        expect(APISessionToken.token_user_class).to eq(Employee)
      end
    end

    context "When using a string for user_model" do
      let(:user_model) { 'Admin' }
      it "returns the specified User class" do
        expect(APISessionToken.token_user_class).to eq(Admin)
      end
    end
  end

  describe ".updated_at" do
    context "When checking a new session" do
      let(:subject) { APISessionToken.disburse() }
      it "returns a recent timestamp" do
        t = Time.now
        expect(t-1...t+1).to cover(subject.updated_at)
      end
    end
  end

  describe ".authenticate_as & .identify_user" do
    before do
      SandDollar.configure do |config|
        config.user_model = user_model
      end
    end

    context "When using the default config" do
      let(:user_model) { nil }

      it "responds to authenticate_as method" do
        subject = APISessionToken.disburse()
        subject.authenticate_as(1)
        expect(subject.identify_user).to eq(1)
      end

      it "responds to user_id method" do
        subject = APISessionToken.disburse()
        subject.authenticate_as(2)
        expect(subject.respond_to?(:user_id)).to eq(true)
        expect(subject.user_id).to eq(2)
      end
    end

    context "When using a symbol for user_model" do
      let(:user_model) { :employee }
      it "responds to custom user id retrieval method" do
        subject = APISessionToken.disburse()
        subject.authenticate_as(3)
        expect(subject.identify_user).to eq(3)
        expect(subject.respond_to?(:user_id)).to eq(false)
        expect(subject.respond_to?(:employee_id)).to eq(true)
        expect(subject.employee_id).to eq(3)
      end
    end

    context "When using a string for user_model" do
      let(:user_model) { 'Admin' }
      it "responds to custom user id retrieval method" do
        subject = APISessionToken.disburse()
        subject.authenticate_as(4)
        expect(subject.identify_user).to eq(4)
        expect(subject.respond_to?(:user_id)).to eq(false)
        expect(subject.respond_to?(:admin_id)).to eq(true)
        expect(subject.admin_id).to eq(4)
      end
    end
  end

  describe ".ttl" do
    context "When using the default config" do
      let(:life) { SandDollar::Default::SESSION_LIFETIME }

      it "returns approximately the default session_lifetime" do
        subject = APISessionToken.disburse()
        expect(life-1...life).to cover(subject.ttl)
      end

      it "returns a smaller number as time passes" do
        subject = APISessionToken.disburse()
        Delorean.jump(life - 20)
        expect(19...21).to cover(subject.ttl)
      end
    end

    context "When using a custom config" do
      before do
        SandDollar.configure do |config|
          config.session_lifetime = life
        end
      end

      let(:life) { 120 }

      it "returns approximately the specified session_lifetime" do
        subject = APISessionToken.disburse()
        expect(life-1...life).to cover(subject.ttl)
      end

      it "returns a smaller number as time passes" do
        subject = APISessionToken.disburse()
        Delorean.jump(life - 20)
        expect(19...21).to cover(subject.ttl)
      end
    end

  end

  describe ".expired? and .alive?" do

    context "When using the default config" do

      let(:life) { SandDollar::Default::SESSION_LIFETIME }

      it "returns true/false after #{SandDollar::Default::SESSION_LIFETIME} seconds" do
        subject = APISessionToken.disburse()

        expect(subject.expired?).to eq(false)
        expect(subject.alive?).to eq(true)

        Delorean.jump(life - 20)

        expect(subject.expired?).to eq(false)
        expect(subject.alive?).to eq(true)

        Delorean.back_to_the_present
        Delorean.jump(life + 1)

        expect(subject.expired?).to eq(true)
        expect(subject.alive?).to eq(false)
      end
    end

    context "When using a custom config" do
      before do
        SandDollar.configure do |config|
          config.session_lifetime = life
        end
      end

      let(:life) { 120 }

      it "returns true/false after the configured number of seconds" do
        subject = APISessionToken.disburse()

        expect(subject.expired?).to eq(false)
        expect(subject.alive?).to eq(true)

        Delorean.jump(life - 20)

        expect(subject.expired?).to eq(false)
        expect(subject.alive?).to eq(true)

        Delorean.back_to_the_present
        Delorean.jump(life)

        expect(subject.expired?).to eq(true)
        expect(subject.alive?).to eq(false)
      end
    end

  end

  describe ".keep_alive" do

    context "When using the default config" do

      let(:life) { SandDollar::Default::SESSION_LIFETIME }

      it "sets updated_at to now" do
        subject = APISessionToken.disburse()

        Delorean.jump(life - 1)

        subject.keep_alive

        t = Time.now
        expect(t-1...t+1).to cover(subject.updated_at)
        expect(life-1...life).to cover(subject.ttl)
      end

      it "does nothing if expired" do
        subject = APISessionToken.disburse()
        updated_at = subject.updated_at

        Delorean.jump(life + 1)

        subject.keep_alive

        expect(updated_at-1...updated_at+1).to cover(subject.updated_at)
        expect(subject.expired?).to eq(true)
      end
    end

  end

end
