Rails.application.config.generators do |g|
  g.stylesheets false
  g.javascripts false
  g.helper false
  g.skip_routes true
end
#  CSS、JS、Helper関係のファイルの自動生成しない。
#  Routerにルーティングを自動的に追加しない。