require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    subject { build(:user) }  # FactoryBot を利用（事前に factories/user.rb 用意）

    it { should validate_presence_of(:nickname) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:password).is_at_least(6) }
  end

  describe 'パスワードのフォーマット' do
    let(:user) { build(:user) }

    it '英字のみは無効' do
      user.password = user.password_confirmation = 'abcdef'
      expect(user).not_to be_valid
    end

    it '数字のみは無効' do
      user.password = user.password_confirmation = '123456'
      expect(user).not_to be_valid
    end

    it '英字と数字を含む場合は有効' do
      user.password = user.password_confirmation = 'abc123'
      expect(user).to be_valid
    end
  end
end
