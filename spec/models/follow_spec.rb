RSpec.describe Follow, type: :model do
  it { is_expected.to belong_to(:follower).class_name('User') }
  it { is_expected.to belong_to(:followed).class_name('User') }
  it 'prevents self follow' do
    u = create(:user)
    expect { create(:follow, follower: u, followed: u) }.to raise_error(ActiveRecord::RecordInvalid).or raise_error(ActiveRecord::RecordNotUnique)
  end
end
