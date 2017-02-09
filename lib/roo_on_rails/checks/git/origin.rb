require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    module Git
      class Origin < Base
        # Output context:
        # - git_org (string)
        # - git_repo (string)
        def intro
          "Checking your Git origin remote..."
        end

        def call
          status, url = shell "git config remote.origin.url"
          fail! "Origin does not seem to be configured." unless status
          
          org, repo = url.strip.sub(%r{\.git$}, '').split(%r{[:/]}).last(2)
          context.git_org  = org
          context.git_repo = repo
          pass "organisation #{bold org}, repository: #{bold repo}"
        end
      end
    end
  end
end

