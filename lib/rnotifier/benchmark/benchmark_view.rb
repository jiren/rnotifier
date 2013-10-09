module Rnotifier
  class BenchmarkView
    class << self

      def browser_token
        Digest::MD5.hexdigest("#{Rnotifier::Config.app_id}#{Process.pid}#{Thread.current.object_id}#{Time.now.to_i}")
      end

      def tag(token)
        q = ["b_token=#{token}", "app_id=#{Rnotifier::Config.app_id}"].join("&")
        %Q{<script>$.get('#{Rnotifier::Config.api_host}/#{Rnotifier::Config.browser_path}?#{q}&o_at='+(new Date()).getTime())</script>}
      end

    end
  end
end
