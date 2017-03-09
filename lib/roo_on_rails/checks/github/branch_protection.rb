require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/git/origin'
require 'roo_on_rails/checks/github/token'

module RooOnRails
  module Checks
    module GitHub
      class BranchProtection < Base
        requires GitHub::Token, Git::Origin

        CI_CONTEXTS = %w(
          ci/circle-ci
          continuous-integration/travis-ci
        ).freeze
        private_constant :CI_CONTEXTS

        def intro
          'Checking if GitHub master branch is protected...'
        end

        def call
          ensure_strict!
          ensure_ci!
          ensure_reviews!
          ensure_no_push!
          pass 'branch protection enabled'
        end

        def fix
          old_status_checks = protection[:required_status_checks] || {}
          new_status_checks = old_status_checks.merge(
            strict: true,
            include_admins: true,
            contexts: (old_status_checks[:contexts] || []) | [ci_context]
          )

          old_reviews = protection[:required_pull_request_reviews] || {}
          new_reviews = old_reviews.merge(include_admins: true)

          old_restrictions = protection[:restrictions] || {}
          new_restrictions = old_restrictions.merge(users: [], teams: [])

          client.protect_branch(
            repo,
            branch,
            options.merge(
              required_status_checks: new_status_checks,
              required_pull_request_reviews: new_reviews,
              restrictions: new_restrictions
            )
          )
        end

        private

        def ensure_strict!
          status_checks = protection[:required_status_checks] || {}
          fail! 'branch protection is not strict' unless status_checks[:strict]
          fail! 'branch protection does not include admins' unless status_checks[:include_admins]
        end

        def ensure_ci!
          contexts = protection.dig(:required_status_checks, :contexts) || []
          fail! 'ci branch protection missing' unless (CI_CONTEXTS & contexts).any?
        end

        def ensure_reviews!
          reviews = protection[:required_pull_request_reviews] || {}
          fail! 'code reviews do not include admins' unless reviews[:include_admins]
        end

        def ensure_no_push!
          users = protection.dig(:restrictions, :users) || []
          teams = protection.dig(:restrictions, :teams) || []
          fail! 'no users or teams should be allowed to push to master' if users.any? || teams.any?
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
