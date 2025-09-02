RSpec.describe Cheer, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:log).counter_cache(:cheers_count).optional(false) }
end
