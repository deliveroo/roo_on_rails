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
          ensure_status_checks!
          ensure_code_reviews!
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
              restrictions: fixed_restrictions,
              enforce_admins: true
            )
          )
        end

        private

        def ensure_status_checks!
          status_checks = protection[:required_status_checks] || {}
          enforce_admins = protection[:enforce_admins]
          fail! 'status checks are not enforced for admins' unless enforce_admins &&
                                                                   enforce_admins[:enabled]

          contexts = status_checks[:contexts] || []
          ensure_ci_status_check!(contexts)
          ensure_analysis_status_check!(contexts)
          ensure_coverage_status_check!(contexts)
        end

        def ensure_ci_status_check!(contexts)
          fail! 'no continuous integration status check' unless contexts.include?(ci_context)
        end

        def ensure_analysis_status_check!(contexts)
          fail! 'no code analysis status check' unless contexts.include?(analysis_context)
        end

        def ensure_coverage_status_check!(contexts)
          return if (contexts & coverage_contexts).sort == coverage_contexts.sort
          fail! 'no code coverage status checks'
        end

        def ensure_code_reviews!
          reviews = protection[:required_pull_request_reviews] || {}
          fail! 'code approvals should be dismissed on push' unless reviews[:dismiss_stale_reviews]

          users = reviews.dig(:dismissal_restrictions, :users)
          teams = reviews.dig(:dismissal_restrictions, :teams)
          fail! 'review dismissal restrictions should be enabled' if users.nil? || teams.nil?
          fail! 'nobody should be allowed to dismiss reviews' if users.any? || teams.any?
        end

        def ensure_no_push!
          users = protection.dig(:restrictions, :users)
          teams = protection.dig(:restrictions, :teams)
          fail! 'push restrictions should be enabled' if users.nil? || teams.nil?
          fail! 'nobody should be allowed to push to master' if users.any? || teams.any?
        end

        def fixed_required_status_checks
          status_checks = protection[:required_status_checks] || {}
          status_checks.merge(
            contexts: (status_checks[:contexts] || []) | [
              ci_context,
              analysis_context,
              *coverage_contexts
            ]
          )
        end

        def fixed_pull_request_reviews
          reviews = protection[:required_pull_request_reviews] || {}
          reviews.merge(
            dismiss_stale_reviews: true,
            dismissal_restrictions: { users: [], teams: [] }
          )
        end

        def fixed_restrictions
          restrictions = protection[:restrictions] || {}
          restrictions.merge(users: [], teams: [])
        end

        def ci_context
          if Pathname.new('.travis.yml').exist? then 'continuous-integration/travis-ci'
          else 'ci/circleci'
          end
        end

        def analysis_context
          'codeclimate'
        end

        def coverage_contexts
          %w(codecov/patch codecov/project)
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
