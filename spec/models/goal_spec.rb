RSpec.describe Goal, type: :model do
  subject(:goal) { build(:goal) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to define_enum_for(:visibility).with_values(%i[public followers private]).backed_by_column_of_type(:integer) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:favorites).dependent(:destroy) }
end
