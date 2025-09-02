# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# ------- Addons: support 配下の読み込み -------
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# ------- shoulda-matchers 設定 -------
require 'shoulda/matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # fixtures
  config.fixture_paths = [Rails.root.join('spec/fixtures')]

  # トランザクション（モデル中心ならこれでOK）
  config.use_transactional_fixtures = true

  # spec の配置場所から type を自動推定（models/ など）
  config.infer_spec_type_from_file_location!

  # Rails 由来のバックトレースを省略
  config.filter_rails_from_backtrace!

  # ------- FactoryBot / 時刻固定（travel_to） -------
  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers

  # ------- （任意）System Spec のドライバ設定例 -------
  # Capybara を使う場合のデフォルト（非JS）
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
  # JS を使う System Spec は headless Chrome
  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome
  end
end
