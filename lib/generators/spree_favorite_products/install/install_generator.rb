require 'spree_extension'

module SpreeFavoriteProducts
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include SpreeExtension::ComponentsChecker

      class_option :auto_run_migrations, type: :boolean, default: false

      def add_javascripts
        if self.class.frontend_available?
          append_file 'vendor/assets/javascripts/spree/frontend/all.js', "\n//= require store/spree_favorite_products\n"
          append_file 'vendor/assets/javascripts/spree/frontend/all.js', "\n//= require spree/frontend/spree_favorite_products\n"
        end
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "\n//= require admin/spree_favorite_products\n"
      end

      def add_stylesheets
        if self.class.frontend_available?
          inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', " *= require store/spree_favorite_products\n", before: /\*\//, verbose: true
        end
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require admin/spree_favorite_products\n", before: /\*\//, verbose: true
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_favorite_products'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
      end
    end
  end
end
