require "test_helper"

class UserTest < ActiveSupport::TestCase
  def valid_user(overrides = {})
    User.new({
      name: "João Silva",
      email: "joao@example.com",
      password: "password123",
      password_confirmation: "password123"
    }.merge(overrides))
  end

  # --- validations ---

  test "is valid with name, email and password" do
    assert valid_user.valid?
  end

  test "is invalid without name" do
    user = valid_user(name: "")
    assert_not user.valid?
    assert user.errors.where(:name, :blank).any?
  end

  test "is invalid without email" do
    user = valid_user(email: "")
    assert_not user.valid?
  end

  test "is invalid with duplicate email" do
    valid_user.save!
    duplicate = valid_user(name: "Outro")
    assert_not duplicate.valid?
  end

  # --- role enum ---

  test "default role is participant" do
    user = valid_user
    assert user.participant?
    assert_not user.admin?
  end

  test "can be assigned admin role" do
    user = valid_user(role: "admin")
    assert user.admin?
    assert_not user.participant?
  end

  test "raises on unknown role" do
    assert_raises(ArgumentError) { valid_user(role: "superuser") }
  end
end
