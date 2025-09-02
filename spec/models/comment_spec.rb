RSpec.describe Comment, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:log) }
  it { is_expected.to validate_presence_of(:body) }
end
