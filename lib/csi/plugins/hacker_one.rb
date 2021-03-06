# frozen_string_literal: true

require 'json'
require 'base64'

module CSI
  module Plugins
    # This plugin is used for interacting w/ HackerOne's REST API using
    # the 'rest' browser type of CSI::Plugins::TransparentBrowser.
    module HackerOne
      @@logger = CSI::Plugins::CSILogger.create

      # Supported Method Parameters::
      # h1_obj = CSI::Plugins::HackerOne.login(
      #   username: 'required - username',
      #   token: 'optional - api token (will prompt if nil)'
      # )

      public

      def self.login(opts = {})
        username = opts[:username].to_s.scrub
        base_h1_api_uri = 'https://api.hackerone.com/v1/'.to_s.scrub

        token = if opts[:token].nil?
                  CSI::Plugins::AuthenticationHelper.mask_password
                else
                  opts[:token].to_s.scrub
                end

        auth_payload = {}
        auth_payload[:username] = username
        auth_payload[:token] = token

        base64_str = "#{username}:#{token}"
        base64_encoded_auth = Base64.encode64(base64_str).to_s.chomp
        basic_auth_header = "Basic #{base64_encoded_auth}"

        @@logger.info("Logging into HackerOne REST API: #{base_h1_api_uri}")
        rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request
        response = rest_client.execute(
          method: :get,
          url: base_h1_api_uri,
          headers: {
            authorization: basic_auth_header,
            content_type: 'application/json; charset=UTF-8'
          }
        )

        # Return array containing the post-authenticated HackerOne REST API token
        json_response = JSON.parse(response, symbolize_names: true)
        h1_success = json_response['success']
        api_token = json_response['token']
        h1_obj = {}
        h1_obj[:h1_success] = h1_success
        h1_obj[:api_token] = api_token
        h1_obj[:raw_response] = response

        return h1_obj
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # h1_rest_call(
      #   h1_obj: 'required h1_obj returned from #login method',
      #   http_method: 'optional HTTP method (defaults to GET)
      #   rest_call: 'required rest call to make per the schema',
      #   http_body: 'optional HTTP body sent in HTTP methods that support it e.g. POST'
      # )

      private

      def self.h1_rest_call(opts = {})
        h1_obj = opts[:h1_obj]
        http_method = if opts[:http_method].nil?
                        :get
                      else
                        opts[:http_method].to_s.scrub.to_sym
                      end
        rest_call = opts[:rest_call].to_s.scrub
        http_body = opts[:http_body].to_s.scrub
        h1_success = h1_obj[:h1_success].to_s.scrub
        base_h1_api_uri = 'https://api.hackerone.com/v1/'.to_s.scrub
        api_token = h1_obj[:api_token]

        rest_client = CSI::Plugins::TransparentBrowser.open(browser_type: :rest)::Request

        case http_method
        when :get
          response = rest_client.execute(
            method: :get,
            url: "#{base_h1_api_uri}/#{rest_call}",
            headers: {
              content_type: 'application/json; charset=UTF-8',
              params: { token: api_token }
            }
          )

        when :post
          response = rest_client.execute(
            method: :post,
            url: "#{base_h1_api_uri}/#{rest_call}",
            headers: {
              content_type: 'application/json; charset=UTF-8'
            },
            payload: http_body
          )

        else
          raise @@logger.error("Unsupported HTTP Method #{http_method} for #{self} Plugin")
        end
      rescue => e
        raise e.message
      end

      # Supported Method Parameters::
      # CSI::Plugins::HackerOne.logout(
      #   h1_obj: 'required h1_obj returned from #login method'
      # )

      public

      def self.logout(opts = {})
        h1_obj = opts[:h1_obj]
        @@logger.info('Logging out...')
        h1_obj = nil
      rescue => e
        raise e.message
      end

      # Author(s):: Jacob Hoopes <jake.hoopes@gmail.com>

      public

      def self.authors
        authors = "AUTHOR(S):
          Jacob Hoopes <jake.hoopes@gmail.com>
        "

        authors
      end

      # Display Usage for this Module

      public

      def self.help
        puts "USAGE:
          h1_obj = #{self}.login(
            username: 'required username',
            token: 'optional api token (will prompt if nil)'
          )

          h1_obj = #{self}.logout(
            h1_obj: 'required h1_obj returned from #login method'
          )

          #{self}.authors
        "
      end
    end
  end
end
