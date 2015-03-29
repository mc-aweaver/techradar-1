require "rails_helper"

describe User do
  let(:attrs) { attributes_for(:user) }

  it "creates a new instance given a valid attribute" do
    expect { described_class.create!(attrs) }.not_to raise_error
  end

  it "publishes a message on creation" do # https://github.com/krisleech/wisper/issues/60
    expect { create(:user) }.to broadcast(:user_created)
  end

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:email) }

  it "accepts valid email addresses" do
    addresses = %w(user@foo.com THE_USER@foo.bar.org first.last@foo.jp)
    addresses.each do |address|
      valid_email_user = described_class.new(attrs.merge(email: address))
      expect(valid_email_user).to be_valid
    end
  end

  it "rejects invalid email addresses" do
    addresses = %w(user@foo,com user_at_foo.org example.user@foo.)
    addresses.each do |address|
      invalid_email_user = described_class.new(attrs.merge(email: address))
      expect(invalid_email_user).not_to be_valid
    end
  end

  it { should validate_uniqueness_of(:email).case_insensitive }

  describe "passwords" do
    let(:user) { described_class.new(attrs) }

    it "has a password attribute" do
      expect(user).to respond_to(:password)
    end

    it "has a password confirmation attribute" do
      expect(user).to respond_to(:password_confirmation)
    end
  end

  describe "password validations" do
    it { should validate_presence_of(:password) }
    it { should validate_confirmation_of(:password) }
    it { should ensure_length_of(:password).is_at_least(8) }
  end

  describe "password encryption" do
    let(:user) { described_class.create!(attrs) }

    it "has an encrypted password attribute" do
      expect(user).to respond_to(:encrypted_password)
    end

    it "sets the encrypted password attribute" do
      expect(user.encrypted_password).not_to be_blank
    end
  end

  describe "#admin" do
    it "returns the admin account if present" do
      admin = create(:user, admin: true)
      expect(described_class.admin.id).to eq admin.id
    end

    it "raises User::MissingAdminAccount if not present" do
      expect { described_class.admin }.to raise_error(User::MissingAdminAccount)
    end
  end

  describe "#already_has_topics?" do
    specify do
      user = create(:user)
      create(:topic, creator: user)

      expect(user.already_has_topics?).to be(false)
    end

    specify do
      user = create(:user)
      2.times do
        create(:topic, creator: user)
      end

      expect(user.already_has_topics?).to be(true)
    end
  end
end
