## Using the Google OAuth feature

This feature is only supported when using Rails 5+.

`roo_on_rails` provides a pre-baked Omniauth setup to help protect your app with
Google authentication. Read the main `README` first to set things up; you'll
need at least `GOOGLE_AUTH_ENABLED=YES`, and `GOOGLE_AUTH_CLIENT_ID` and
`GOOGLE_AUTH_CLIENT_SECRET` configured.

Let's build a tiny app that has just a homepage, prompts you to sign in, and
show your email once you have.

We add the landing page route:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root to: 'landing#index'
end
```

And a controller/view:

```ruby
# app/controllers/landing_controller.rb
class LandingController < ApplicationController
  def index
    if session[:email]
      render inline: %{
        You are logged in as <%= session[:email] %>! <br/>
        <%= link_to 'Logout', auth_logout_path %>
      }
    else
      render inline: %{
        You are not logged in <br/>
        <%= link_to 'Login', auth_google_oauth2_path %>
      }
    end
  end
end
```

The authentication routes get added by `roo_on_rails`; we need to implement at
least session creation, destruction, and handling of failure:

```ruby
# app/controllers/sessions_controller.rb

class SessionsController < ApplicationController
  def create
    auth_data = request.env['omniauth.auth']
    session[:email] = auth_data.info.email.downcase
    redirect_to root_path
  end

  def destroy
    session.clear
    redirect_to root_path
  end

  def failure
    @error = env['omniauth.error']
    render inline: %{
      Authentication failed: <br/>
      <%= @error.class.name %> <br/>
      <%= @error.message %>
    }
  end
end
```

And that's it. If you want to blanket-protect a controller, an idiomatic way
would be to:

```ruby
before_filter { redirect_to auth_google_oauth2_path unless session[:email] }
```

If you dislike the name `SessionsController`, you can update
`GOOGLE_AUTH_CONTROLLER` to point to a different controller.

You can also change the `/auth` path prefix used by this feature; in this case
you'll want to update the example above. For instance, if you change `/auth` to
`/prefix`, `auth_google_oauth2_path` becomes `prefix_google_oauth2_path`.
