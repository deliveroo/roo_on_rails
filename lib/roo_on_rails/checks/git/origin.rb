require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    module Git
      class Origin < Base
        def _intro
          "Checking your Git origin remote..."
        end

        def _call
          status, url = _run "git config remote.origin.url"
          _fail "Origin does not seem to be configured." unless status
          
          org, repo = url.strip.gsub(%r{\.git$}, '').split(%r{[:/]}).last(2)
          _state.git_org  = org
          _state.git_repo = repo
          _ok "organisation #{bold org}, repository: #{bold repo}"
        end
      end
    end
  end
end

