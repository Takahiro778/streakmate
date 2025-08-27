require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(
      nickname: 'Taro',
      email: 'taro@example.com',
      password: 'abc123',
      password_confirmation: 'abc123'
    )
  end

  it 'nicknameが必須であること' do
    @user.nickname = ''
    expect(@user).not_to be_valid
  end

  it 'emailが一意であること' do
    @user.save
    user2 = @user.dup
    expect(user2).not_to be_valid
  end

  it 'passwordが6文字以上であること' do
    @user.password = 'a1b2'
    @user.password_confirmation = 'a1b2'
    expect(@user).not_to be_valid
  end

  it 'passwordが英字と数字を含むこと' do
    @user.password = 'abcdef'
    @user.password_confirmation = 'abcdef'
    expect(@user).not_to be_valid
  end
end
