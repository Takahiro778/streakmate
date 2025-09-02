RSpec.describe Goal, type: :model do
  subject(:goal) = { build(:goal) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:favorites).dependent(:destroy) }

  it 'has category via ActiveHash' do
    g = build(:goal, category_id: 1)
    expect(g).to respond_to(:category)
  end
end
