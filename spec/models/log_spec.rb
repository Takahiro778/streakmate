require 'rails_helper'

RSpec.describe Log, type: :model do
  subject(:log) { build(:log) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:cheers).dependent(:destroy) }
  it { is_expected.to have_many(:comments).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:minutes) }
  it { is_expected.to validate_inclusion_of(:minutes).in_array(Log::VALID_MINUTES) }
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:visibility) }

  # ✅ enum に _prefix: true を使っているため .with_prefix を追加
  it {
    expect(log).to define_enum_for(:category)
      .with_values(%i[study work exercise rest])
      .backed_by_column_of_type(:integer)
      .with_prefix
  }

  it {
    expect(log).to define_enum_for(:visibility)
      .with_values(%i[public followers private])
      .backed_by_column_of_type(:integer)
      .with_prefix
  }

  describe '.on_day / .this_week' do
    it 'filters by date with travel_to' do
      u = create(:user)
      travel_to Time.zone.parse('2025-09-02 10:00') do
        today = create(:log, user: u)
        yesterday = create(:log, user: u, created_at: 1.day.ago)
        expect(Log.on_day(Date.current)).to include(today)
        expect(Log.on_day(Date.current)).not_to include(yesterday)
        expect(Log.this_week).to include(today)
      end
    end
  end

  describe '.visible_to(viewer)' do
    it 'returns public for guest, and adds mine/followers for logged-in' do
      owner    = create(:user)
      follower = create(:user)
      stranger = create(:user)
      create(:follow, follower: follower, followed: owner)

      pub  = create(:log, user: owner, visibility: :public)
      fol  = create(:log, user: owner, visibility: :followers)
      priv = create(:log, user: owner, visibility: :private)

      expect(Log.visible_to(nil)).to contain_exactly(pub)

      expect(Log.visible_to(follower)).to include(pub, fol)
      expect(Log.visible_to(follower)).not_to include(priv)

      expect(Log.visible_to(stranger)).to contain_exactly(pub)

      # 自分自身は private も見える
      mine_priv = create(:log, user: follower, visibility: :private)
      expect(Log.visible_to(follower)).to include(mine_priv)
    end
  end

  describe '#cheered_by?' do
    it 'detects cheer by user' do
      u = create(:user)
      l = create(:log)
      create(:cheer, user: u, log: l)
      expect(l.cheered_by?(u)).to be true
    end
  end

  describe '#commentable_by?' do
    it 'allows own or public or followers when followed' do
      owner = create(:user)
      follower = create(:user)
      create(:follow, follower: follower, followed: owner)
      public_log = create(:log, user: owner, visibility: :public)
      followers_log = create(:log, user: owner, visibility: :followers)
      expect(public_log.commentable_by?(follower)).to be true
      expect(followers_log.commentable_by?(follower)).to be true
    end
  end
end
