require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/git/origin'
require 'roo_on_rails/checks/github/token'

module RooOnRails
  module Checks
    module GitHub
      class BranchProtection < Base
        requires GitHub::Token, Git::Origin

        def intro
          'Checking if GitHub master branch is protected...'
        end

        def call
          ensure_strict!
          ensure_ci!
          ensure_reviews!
          ensure_no_push!
          pass 'branch protection is sufficient'
        end

        def fix
          client.protect_branch(
            repo,
            branch,
            options.merge(
              required_status_checks: fixed_required_status_checks,
              required_pull_request_reviews: fixed_pull_request_reviews,
              restrictions: fixed_restrictions
            )
          )
        end

        private

        def ensure_strict!
          status_checks = protection[:required_status_checks] || {}
          fail! 'status checks do not include admins' unless status_checks[:include_admins]
        end

        def ensure_ci!
          contexts = protection.dig(:required_status_checks, :contexts) || []
          fail! 'CI missing from status checks' unless contexts.include?(ci_context)
        end

        def ensure_reviews!
          reviews = protection[:required_pull_request_reviews] || {}
          fail! 'code reviews do not include admins' unless reviews[:include_admins]
        end

        def ensure_no_push!
          users = protection.dig(:restrictions, :users)
          teams = protection.dig(:restrictions, :teams)
          fail! 'push restrictions should be enabled' if users.nil? || teams.nil?
          fail! 'no users or teams should be allowed to push to master' if users.any? || teams.any?
        end

        def fixed_required_status_checks
          status_checks = protection[:required_status_checks] || {}
          status_checks.merge(
            include_admins: true,
            contexts: (status_checks[:contexts] || []) | [ci_context]
          )
        end

        def fixed_pull_request_reviews
          reviews = protection[:required_pull_request_reviews] || {}
          reviews.merge(include_admins: true)
        end

        def fixed_restrictions
          restrictions = protection[:restrictions] || {}
          restrictions.merge(users: [], teams: [])
        end

        def ci_context
          if Pathname.new('.travis.yml').exist? then 'continuous-integration/travis-ci'
          else 'ci/circle-ci'
          end
        end

        def protection
          client.branch_protection(repo, branch, options).to_h
        end

        def repo
          "#{context.git_org}/#{context.git_repo}"
        end

        def branch
          'master'
        end

        def options
          accept = Octokit::Preview::PREVIEW_TYPES[:branch_protection]
          accept ? { accept: accept } : {}
        end

        def client
          context.github.api_client
        end
      end
    end
  end
end
