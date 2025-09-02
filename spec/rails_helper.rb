# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'pundit/rspec'
require 'shoulda/matchers'
require 'capybara/rspec' # system spec を使う場合は明示しておくと安心
# require 'database_cleaner/active_record' # JS system spec を増やす時に使う想定

# ------- support 配下の読み込み -------
Rails.root.glob('spec/support/**/*.rb').sort_by(&:to_s).each { |f| require f }

# ------- shoulda-matchers 設定 -------
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  # fixtures
  config.fixture_paths = [Rails.root.join('spec/fixtures')]

  # モデル中心ならトランザクションでOK（JS付きSystemを増やす場合は調整）
  config.use_transactional_fixtures = true

  # spec の配置場所から type を自動推定（models/ など）
  config.infer_spec_type_from_file_location!

  # Rails 由来のバックトレースを省略
  config.filter_rails_from_backtrace!

  # ------- FactoryBot / 時刻固定（travel_to） -------
  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers

  # ------- Devise ヘルパ -------
  # request / system で sign_in を使えるように
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  # controller spec を書く場合
  config.include Devise::Test::ControllerHelpers, type: :controller

  # ------- System Spec のドライバ設定 -------
  Capybara.server = :puma, { Silent: true }

  # 非JS（デフォルト）
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  # JS ありのときは headless Chrome
  config.before(:each, type: :system, js: true) do
    driven_by :selenium, using: :headless_chrome
  end

  # ▼ JS system を本格運用する時に DatabaseCleaner を使うならこのブロックを有効化
  # config.use_transactional_fixtures = false
  # config.before(:suite) do
  #   DatabaseCleaner[:active_record].strategy = :transaction
  #   DatabaseCleaner[:active_record].clean_with(:truncation)
  # end
  # config.around(:each) do |example|
  #   if example.metadata[:js]
  #     DatabaseCleaner[:active_record].strategy = :truncation
  #     DatabaseCleaner[:active_record].cleaning { example.run }
  #     DatabaseCleaner[:active_record].strategy = :transaction
  #   else
  #     DatabaseCleaner[:active_record].cleaning { example.run }
  #   end
  # end
end
