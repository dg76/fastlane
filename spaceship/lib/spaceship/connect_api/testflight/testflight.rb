require 'spaceship/connect_api/testflight/client'

module Spaceship
  class ConnectAPI
    module TestFlight
      module API
        def test_flight_request_client=(test_flight_request_client)
          @test_flight_request_client = test_flight_request_client
        end

        def test_flight_request_client
          return @test_flight_request_client if @test_flight_request_client
          raise TypeError, "You need to instantiate this module with test_flight_request_client"
        end

        #
        # apps
        #

        def get_apps(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("apps", params)
        end

        def get_app(app_id: nil, includes: nil)
          params = test_flight_request_client.build_params(filter: nil, includes: includes, limit: nil, sort: nil)
          test_flight_request_client.get("apps/#{app_id}", params)
        end

        #
        # betaAppLocalizations
        #

        def get_beta_app_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("betaAppLocalizations", params)
        end

        def post_beta_app_localizations(app_id: nil, attributes: {})
          body = {
            data: {
              attributes: attributes,
              type: "betaAppLocalizations",
              relationships: {
                app: {
                  data: {
                    type: "apps",
                    id: app_id
                  }
                }
              }
            }
          }

          test_flight_request_client.post("betaAppLocalizations", body)
        end

        def patch_beta_app_localizations(localization_id: nil, attributes: {})
          body = {
            data: {
              attributes: attributes,
              id: localization_id,
              type: "betaAppLocalizations"
            }
          }

          test_flight_request_client.patch("betaAppLocalizations/#{localization_id}", body)
        end

        #
        # betaAppReviewDetails
        #

        def get_beta_app_review_detail(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("betaAppReviewDetails", params)
        end

        def patch_beta_app_review_detail(app_id: nil, attributes: {})
          body = {
            data: {
              attributes: attributes,
              id: app_id,
              type: "betaAppReviewDetails"
            }
          }

          test_flight_request_client.patch("betaAppReviewDetails/#{app_id}", body)
        end

        #
        # betaAppReviewSubmissions
        #

        def get_beta_app_review_submissions(filter: {}, includes: nil, limit: nil, sort: nil, cursor: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort, cursor: cursor)
          test_flight_request_client.get("betaAppReviewSubmissions", params)
        end

        #
        # betaAppReviewSubmissions
        #

        def get_beta_app_review_submission_state_for_build(build_id: nil)
          response = test_flight_request_client.get("builds/#{build_id}/betaAppReviewSubmission", {})
          if response.body["data"].nil?
            return nil
          end
          return response.body["data"]["attributes"]["betaReviewState"]
        end

        def post_beta_app_review_submissions(build_id: nil)
          body = {
            data: {
              type: "betaAppReviewSubmissions",
              relationships: {
                build: {
                  data: {
                    type: "builds",
                    id: build_id
                  }
                }
              }
            }
          }

          test_flight_request_client.post("betaAppReviewSubmissions", body)
        end

        def delete_beta_app_review_submission(beta_app_review_submission_id: nil)
          params = test_flight_request_client.build_params(filter: nil, includes: nil, limit: nil, sort: nil, cursor: nil)
          test_flight_request_client.delete("betaAppReviewSubmissions/#{beta_app_review_submission_id}", params)
        end

        #
        # betaBuildLocalizations
        #

        def get_beta_build_localizations(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("betaBuildLocalizations", params)
        end

        def post_beta_build_localizations(build_id: nil, attributes: {})
          body = {
            data: {
              attributes: attributes,
              type: "betaBuildLocalizations",
              relationships: {
                build: {
                  data: {
                    type: "builds",
                    id: build_id
                  }
                }
              }
            }
          }

          test_flight_request_client.post("betaBuildLocalizations", body)
        end

        def patch_beta_build_localizations(localization_id: nil, feedbackEmail: nil, attributes: {})
          body = {
            data: {
              attributes: attributes,
              id: localization_id,
              type: "betaBuildLocalizations"
            }
          }

          test_flight_request_client.patch("betaBuildLocalizations/#{localization_id}", body)
        end

        #
        # betaBuildMetrics
        #

        def get_beta_build_metrics(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("betaBuildMetrics", params)
        end

        #
        # betaGroups
        #

        def get_beta_groups(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("betaGroups", params)
        end

        def add_beta_groups_to_build(build_id: nil, beta_group_ids: [])
          body = {
            data: beta_group_ids.map do |id|
              {
                type: "betaGroups",
                id: id
              }
            end
          }

          test_flight_request_client.post("builds/#{build_id}/relationships/betaGroups", body)
        end

        def add_individual_testers_to_build(build_id: nil, beta_tester_ids: [])
          body = {
            data: beta_tester_ids.map do |id|
              {
                type: "betaTesters",
                id: id
              }
            end
          }

          test_flight_request_client.post("builds/#{build_id}/relationships/individualTesters", body)
        end

        def delete_beta_groups_from_build(build_id: nil, beta_group_ids: [])
          body = {
            data: beta_group_ids.map do |id|
              {
                type: "betaGroups",
                id: id
              }
            end
          }

          test_flight_request_client.delete("builds/#{build_id}/relationships/betaGroups", nil, body)
        end

        def create_beta_group(app_id: nil, group_name: nil, is_internal_group: false, public_link_enabled: false, public_link_limit: 10_000, public_link_limit_enabled: false)
          body = {
            data: {
              attributes: {
                name: group_name,
                isInternalGroup: is_internal_group,
                hasAccessToAllBuilds: is_internal_group ? true : false, # Undocumented of 2021-08-02 in ASC API docs and ASC Open API spec. This is the default behavior on App Store Connect and does work with both Apple ID and API Token
                publicLinkEnabled: public_link_enabled,
                publicLinkLimit: public_link_limit,
                publicLinkLimitEnabled: public_link_limit_enabled
              },
              relationships: {
                app: {
                  data: {
                    id: app_id,
                    type: "apps"
                  },
                },
              },
              type: "betaGroups",
            },
          }
          test_flight_request_client.post("betaGroups", body)
        end

        def patch_group(group_id: nil, attributes: {})
          body = {
            data: {
              attributes: attributes,
              id: group_id,
              type: "betaGroups"
            }
          }

          test_flight_request_client.patch("betaGroups/#{group_id}", body)
        end

        def delete_beta_group(group_id: nil)
          raise "group_id is nil" if group_id.nil?

          test_flight_request_client.delete("betaGroups/#{group_id}")
        end

        def get_builds_for_beta_group(group_id: nil)
          raise "group_id is nil" if group_id.nil?

          test_flight_request_client.get("betaGroups/#{group_id}/builds")
        end

        #
        # betaTesters
        #

        def get_beta_testers(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("betaTesters", params)
        end

        # beta_testers - [{email: "", firstName: "", lastName: ""}]
        def post_bulk_beta_tester_assignments(beta_group_id: nil, beta_testers: nil)
          beta_testers || []

          beta_testers.map do |tester|
            tester[:errors] = []
          end

          body = {
            data: {
              attributes: {
                betaTesters: beta_testers
              },
              relationships: {
                betaGroup: {
                  data: {
                    type: "betaGroups",
                    id: beta_group_id
                  }
                }
              },
              type: "bulkBetaTesterAssignments"
            }
          }

          test_flight_request_client.post("bulkBetaTesterAssignments", body)
        end

        def add_beta_tester_to_group(beta_group_id: nil, beta_tester_ids: nil)
          beta_tester_ids || []
          body = {
            data: beta_tester_ids.map do |id|
              {
                type: "betaTesters",
                id: id
              }
            end
          }
          test_flight_request_client.post("betaGroups/#{beta_group_id}/relationships/betaTesters", body)
        end

        def delete_beta_tester_from_apps(beta_tester_id: nil, app_ids: [])
          body = {
            data: app_ids.map do |id|
              {
                type: "apps",
                id: id
              }
            end
          }

          test_flight_request_client.delete("betaTesters/#{beta_tester_id}/relationships/apps", nil, body)
        end

        def delete_beta_tester_from_beta_groups(beta_tester_id: nil, beta_group_ids: [])
          body = {
            data: beta_group_ids.map do |id|
              {
                type: "betaGroups",
                id: id
              }
            end
          }

          test_flight_request_client.delete("betaTesters/#{beta_tester_id}/relationships/betaGroups", nil, body)
        end

        def delete_beta_testers_from_app(beta_tester_ids: [], app_id: nil)
          body = {
            data: beta_tester_ids.map do |id|
              {
                type: "betaTesters",
                id: id
              }
            end
          }

          test_flight_request_client.delete("apps/#{app_id}/relationships/betaTesters", nil, body)
        end

        def add_beta_tester_to_builds(beta_tester_id: nil, build_ids: [])
          body = {
            data: build_ids.map do |id|
              {
                type: "builds",
                id: id
              }
            end
          }

          test_flight_request_client.post("betaTesters/#{beta_tester_id}/relationships/builds", body)
        end

        def add_beta_testers_to_build(build_id: nil, beta_tester_ids: [])
          body = {
            data: beta_tester_ids.map do |id|
              {
                type: "betaTesters",
                id: id
              }
            end
          }

          test_flight_request_client.post("builds/#{build_id}/relationships/individualTesters", body)
        end

        def delete_beta_testers_from_build(build_id: nil, beta_tester_ids: [])
          body = {
            data: beta_tester_ids.map do |id|
              {
                type: "betaTesters",
                id: id
              }
            end
          }

          test_flight_request_client.delete("builds/#{build_id}/relationships/individualTesters", nil, body)
        end

        #
        # betaTesterMetrics
        #

        def get_beta_tester_metrics(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("betaTesterMetrics", params)
        end

        #
        # builds
        #

        def get_builds(filter: {}, includes: "buildBetaDetail,betaBuildMetrics", limit: 10, sort: "uploadedDate", cursor: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort, cursor: cursor)
          test_flight_request_client.get("builds", params)
        end

        def get_build(build_id: nil, app_store_version_id: nil, includes: nil)
          if build_id
            params = test_flight_request_client.build_params(filter: nil, includes: includes, limit: nil, sort: nil, cursor: nil)
            return test_flight_request_client.get("builds/#{build_id}", params)
          elsif app_store_version_id
            params = test_flight_request_client.build_params(filter: nil, includes: includes, limit: nil, sort: nil, cursor: nil)
            return test_flight_request_client.get("appStoreVersions/#{app_store_version_id}/build", params)
          else
            return nil
          end
        end

        def patch_builds(build_id: nil, attributes: {})
          body = {
            data: {
              attributes: attributes,
              id: build_id,
              type: "builds"
            }
          }

          test_flight_request_client.patch("builds/#{build_id}", body)
        end

        #
        # buildBetaDetails
        #

        def get_build_beta_details(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("buildBetaDetails", params)
        end

        def patch_build_beta_details(build_beta_details_id: nil, attributes: {})
          body = {
            data: {
              attributes: attributes,
              id: build_beta_details_id,
              type: "buildBetaDetails"
            }
          }

          test_flight_request_client.patch("buildBetaDetails/#{build_beta_details_id}", body)
        end

        #
        # buildDeliveries
        #

        def get_build_deliveries(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("buildDeliveries", params)
        end

        #
        # preReleaseVersions
        #

        def get_pre_release_versions(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("preReleaseVersions", params)
        end

        #
        # betaFeedbacks (private API as of end 2019)
        #

        def get_beta_feedback(filter: {}, includes: nil, limit: nil, sort: nil)
          params = test_flight_request_client.build_params(filter: filter, includes: includes, limit: limit, sort: sort)
          test_flight_request_client.get("betaFeedbacks", params)
        end

        def delete_beta_feedback(feedback_id: nil)
          raise "Feedback id is nil" if feedback_id.nil?

          test_flight_request_client.delete("betaFeedbacks/#{feedback_id}")
        end
      end
    end
  end
end
