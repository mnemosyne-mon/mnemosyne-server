# Development Notices

## webpack-dev-server

To get live asset compilation and hot-reloading, start the webpack-dev-server using `yarn start`, and the Rails application using `bundle exec rails server`. The Rails server will listen on `localhost:9001`, but the active content security policy and because webpack-dev-server does emit actual files, you must open `localhost:9002` to get assets and hot-reloaded. The webpack-dev-server will proxy all request to `localhost:9002` to the Rails app, but handle `/assets` and hot-reloading itself.
