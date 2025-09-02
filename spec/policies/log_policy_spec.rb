require 'rails_helper'

RSpec.describe LogPolicy do
  subject(:policy) { described_class }

  let(:owner)    { create(:user) }
  let(:follower) { create(:user) }
  let(:stranger) { create(:user) }

  let!(:pub)  { create(:log, user: owner, visibility: :public) }
  let!(:fol)  { create(:log, user: owner, visibility: :followers) }
  let!(:priv) { create(:log, user: owner, visibility: :private) }

  before { create(:follow, follower: follower, followed: owner) }

  permissions :show? do
    it { is_expected.to permit(nil, pub) }
    it { is_expected.not_to permit(nil, fol) }
    it { is_expected.not_to permit(nil, priv) }

    it { is_expected.to permit(owner, pub) }
    it { is_expected.to permit(owner, fol) }
    it { is_expected.to permit(owner, priv) }

    it { is_expected.to permit(follower, pub) }
    it { is_expected.to permit(follower, fol) }
    it { is_expected.not_to permit(follower, priv) }

    it { is_expected.to permit(stranger, pub) }
    it { is_expected.not_to permit(stranger, fol) }
    it { is_expected.not_to permit(stranger, priv) }
  end

  describe 'scope' do
    it 'returns visible records for follower' do
      result = Pundit.policy_scope(follower, Log)
      expect(result).to include(pub, fol)
      expect(result).not_to include(priv)
    end

    it 'returns only public for stranger' do
      result = Pundit.policy_scope(stranger, Log)
      expect(result).to contain_exactly(pub)
    end

    it 'returns public+own for owner' do
      result = Pundit.policy_scope(owner, Log)
      expect(result).to include(pub, fol, priv)
    end

    it 'returns only public for guest' do
      result = Pundit.policy_scope(nil, Log)
      expect(result).to contain_exactly(pub)
    end
  end
end
