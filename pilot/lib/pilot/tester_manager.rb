require 'terminal-table'

require_relative 'manager'

module Pilot
  class TesterManager < Manager
    def add_tester(options)
      start(options)
      app = find_app(apple_id: config[:apple_id], app_identifier: config[:app_identifier])
      UI.user_error!("You must provide either a Apple ID for the app (with the `:apple_id` option) or app identifier (with the `:app_identifier` option)") unless app

      groups_param = config[:groups]
      UI.user_error!("You must provide 1 or more groups (with the `:groups` option)") unless groups_param

      app.get_beta_groups.select do |group|
        next unless groups_param.include?(group.name)
        user = {
          email: config[:email],
          firstName: config[:first_name],
          lastName: config[:last_name]
        }
        group.post_bulk_beta_tester_assignments(beta_testers: [user])
      end

      group_names = groups_param.join(';')
      UI.success("Successfully added tester #{config[:email]} to app #{app.name} in group(s) #{group_names}")
    end

    def add_tester_to_build(options)
      start(options)
      app = find_app(apple_id: config[:apple_id], app_identifier: config[:app_identifier])
      UI.user_error!("You must provide either a Apple ID for the app (with the `:apple_id` option) or app identifier (with the `:app_identifier` option)") unless app

      email_param = config[:email]
      UI.user_error!("You must provide an email address (with the `:email` option)") unless email_param

      if config[:build_number].nil?
        build = app.get_builds.first
      else
        builds = app.get_builds.select do |b|
          config[:build_number] == b.version
        end
        UI.user_error!("Build #{config[:build_number]} not found.") unless builds.count == 1
        build = builds.first
      end
      UI.verbose("Build: #{build.version} id: #{build.id}")

      app.get_beta_testers.select do |tester|
        next unless email_param == tester.email
        app.add_individual_testers_to_build(build_id: build.id, beta_tester_ids: [tester.id])
        UI.success("Added tester: #{tester.email} to build #{build.version} of app #{app.name}.")
      end

      if Spaceship::ConnectAPI.get_beta_app_review_submission_state_for_build(build_id: build.id).nil?
        Spaceship::ConnectAPI.post_beta_app_review_submissions(build_id: build.id)
        UI.success("Posted build #{build.version} of app #{app.name} for beta review.")
      end
    end

    def find_tester(options)
      start(options)

      app = find_app(apple_id: config[:apple_id], app_identifier: config[:app_identifier])

      tester = find_app_tester(email: config[:email], app: app)
      UI.user_error!("Tester #{config[:email]} not found") unless tester

      describe_tester(tester)
      return tester
    end

    def remove_tester(options)
      start(options)

      app = find_app(apple_id: config[:apple_id], app_identifier: config[:app_identifier])

      tester = find_app_tester(email: config[:email], app: app)
      UI.user_error!("Tester #{config[:email]} not found") unless tester

      begin
        # If no groups are passed to options, remove the tester from the app-level,
        # otherwise remove the tester from the groups specified.
        if config[:groups].nil?
          tester.delete_from_apps(apps: [app])
          UI.success("Successfully removed tester #{tester.email} from app: #{app.name}")
        else
          groups = tester.beta_groups.select do |group|
            config[:groups].include?(group.name)
          end
          tester.delete_from_beta_groups(beta_groups: groups)

          group_names = groups.map(&:name)
          UI.success("Successfully removed tester #{tester.email} from app #{app.name} in group(s) #{group_names}")
        end
      rescue => ex
        UI.error("Could not remove #{tester.email} from app: #{ex}")
        raise ex
      end
    end

    def list_testers(options)
      start(options)

      app = find_app(apple_id: config[:apple_id], app_identifier: config[:app_identifier])
      if app
        list_testers_by_app(app)
      else
        UI.user_error!("You must include an `app_identifier` to `list_testers`")
      end
    end

    private

    def find_app(apple_id: nil, app_identifier: nil)
      if app_identifier
        app = Spaceship::ConnectAPI::App.find(app_identifier)
        UI.user_error!("Could not find an app by #{app_identifier}") unless app
        return app
      end

      if apple_id
        app = Spaceship::ConnectAPI::App.get(app_id: apple_id)
        UI.user_error!("Could not find an app by #{apple_id}") unless app
        return app
      end

      UI.user_error!("You must include an `app_identifier` to `list_testers`")
    end

    def find_app_tester(email: nil, app: nil)
      tester = app.get_beta_testers(filter: { email: email }, includes: "apps,betaTesterMetrics,betaGroups").first

      if tester
        UI.success("Found existing tester #{email}")
      end

      return tester
    end

    def list_testers_by_app(app)
      testers = app.get_beta_testers(includes: "apps,betaTesterMetrics,betaGroups")

      list_by_app(testers, "All Testers")
    end

    def list_by_app(all_testers, title)
      headers = ["First", "Last", "Email", "Groups"]
      list(all_testers, "#{title} (#{all_testers.count})", headers) do |tester|
        tester_groups = tester.beta_groups.nil? ? nil : tester.beta_groups.map(&:name).join(";")
        [
          tester.first_name,
          tester.last_name,
          tester.email,
          tester_groups
          # Testers returned by the query made in the context of an app do not contain
          # the version, or install date information
        ]
      end
    end

    # Requires a block that accepts a tester and returns an array of tester column values
    def list(all_testers, title, headings)
      rows = all_testers.map { |tester| yield(tester) }
      puts(Terminal::Table.new(
             title: title.green,
             headings: headings,
             rows: FastlaneCore::PrintTable.transform_output(rows)
      ))
    end

    # Print out all the details of a specific tester
    def describe_tester(tester)
      return unless tester

      rows = []

      rows << ["First name", tester.first_name]
      rows << ["Last name", tester.last_name]
      rows << ["Email", tester.email]

      if tester.beta_groups
        rows << ["Groups", tester.beta_groups.map(&:name).join(";")]
      end

      metric = (tester.beta_tester_metrics || []).first
      if metric.installed?
        rows << ["Latest Version", "#{metric.installed_cf_bundle_short_version_string} (#{metric.installed_cf_bundle_version})"]
        rows << ["Latest Install Date", metric.installed_cf_bundle_version]
        rows << ["Installed", metric.installed?]
      end

      puts(Terminal::Table.new(
             title: tester.email.green,
             rows: FastlaneCore::PrintTable.transform_output(rows)
      ))
    end
  end
end
