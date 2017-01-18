
# Creation of the test app(s)


    rails new spec/support/apps/rails501 \
      --skip-test \
      --skip-git \
      --skip-spring \
      --skip-action-cable \
      --skip-javascript

    # Gemfile
    gem 'roo_on_rails', path: '../../../..'


