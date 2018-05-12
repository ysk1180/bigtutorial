require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Bigtutorial
  class Application < Rails::Application
    config.load_defaults 5.2

    # 以下2つを追加
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
  end
end
