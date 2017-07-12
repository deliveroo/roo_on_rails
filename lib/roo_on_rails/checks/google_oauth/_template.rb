# Google Oauth initializer, generated by RooOnRails

require 'roo_on_rails/rack/google_oauth'

Rails.application.config.middleware.use RooOnRails::Rack::GoogleOauth do |env|
  # This is your auth strategy.
  # Here you're supposed to do something with the OAuth payload and
  # return a valid Rack response.

  # A simple but insecure example:
  #
  require 'digest/md5'
  auth_data = env['omniauth.auth']
  naive_token = Digest::MD5.hexdigest(auth_data.info.email.downcase)
  expires_in = Time.current + 60 * 60 * 24
  headers = {'Location' => '/'}
  Rack::Utils.set_cookie_header!(headers, 'naive_auth_cookie', {
    value: naive_token, expires: expires_in, path: '/'
  })
  [302, headers, ['You are being redirecred to /']]

  # You can also hand it over to a Rails controller#action, where the
  # OAuth payload will be available in `request.env['omniauth.auth']`.
  # If you do this, the controller will take care of returning a valid
  # response for Rack.
  #
  # This is the recommenced approach as it makes it easier to use
  # Rails encrypted cookies and other security features.
  #
  # For example:
  # MyAuthController.action(:login).call(env)
end

# What to do in case of failure.
# Must be a 302 redirect.
# It can invoke a Rails controller#action
#
OmniAuth.config.on_failure = proc do |env|
  # These are available:
  #
  # error = env['omniauth.error']
  # details = error.message
  # error_type = env['omniauth.error.type']
  
  [302, {'Location' => '/'}, ['']]
end

