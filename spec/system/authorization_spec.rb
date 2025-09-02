require 'rails_helper'

RSpec.describe "Authorization", type: :system do
  let!(:owner)  { create(:user) }
  let!(:viewer) { create(:user) } # フォローしていない

  let!(:followers_only_log) { create(:log, user: owner, visibility: :followers, title: "F限定") }

  it "非フォロワーはフォロワー限定の詳細にアクセスできない" do
    # ログインヘルパはアプリの仕組みに合わせて
    login_as(viewer) # Warden の場合
    visit log_path(followers_only_log)

    # 404 を返す設計なので:
    expect(page).to have_content("The page you were looking for doesn't exist")
    expect(page.status_code).to eq 404
  end
end
