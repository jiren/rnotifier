module Rnotifier
  class Config
    DEFAULT = {
      :api_host     => 'http://api.rnotifier.com',
      :api_version  => 'v1', 
      :notify_path  => 'exception',
      :ignore_env   => ['development', 'test'],
      :http_open_timeout => 2,
      :http_read_timeout => 4
    }

    CLIENT = "RN-RUBY-GEM:#{Rnotifier::VERSION}"

    class << self
      attr_accessor :api_key, :notification_path, :environments, :current_env, 
        :valid, :app_env, :api_host, :ignore_exceptions, :capture_code

      def [](val)
        DEFAULT[val]
      end

      def init
        Rlogger.init

        self.valid = false
        self.current_env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development' 
        self.environments ||= []

        if self.environments.is_a?(String) || self.environments.is_a?(Symbol)
          self.environments = self.environments.to_s.split(',')
        end

        #Return if config environments not include current env
        return if !self.environments.empty? && !self.environments.include?(self.current_env)

        #Check for ignore env
        if DEFAULT[:ignore_env].include?(self.current_env) && !self.environments.include?(self.current_env) 
          return
        end

        if self.api_key.nil? and !ENV['RNOTIFIER_API_KEY'].nil?
          self.api_key = ENV['RNOTIFIER_API_KEY']
        end

        return if self.api_key.to_s.length == 0

        self.api_host ||= DEFAULT[:api_host]
        self.notification_path = '/' + [DEFAULT[:api_version], DEFAULT[:notify_path], self.api_key].join('/')
        self.app_env = get_app_env
        self.ignore_exceptions = self.ignore_exceptions.split(',') if self.ignore_exceptions.is_a?(String)

        self.valid = true 
      end

      def valid?
        self.valid
      end

      def get_app_env
        {
          :env => self.current_env,
          :pid => $$,
          :host => (Socket.gethostname rescue ''),
          :user_name => ENV['USER'] || ENV['USERNAME'],
          :program_name => $PROGRAM_NAME,
          :app_root => self.app_root,
          :language => {
            :name => 'ruby',
            :version => (RUBY_VERSION rescue ''),
            :patch_level => (RUBY_PATCHLEVEL rescue ''),
            :platform =>  (RUBY_PLATFORM rescue ''),
            :release_date => (RUBY_RELEASE_DATE rescue ''),
            :ruby_path => Gem.ruby,
            :gem_path => Gem.path
          }
        }
      end

      def app_root
        (defined?(Rails) && Rails.respond_to?(:root)) ? Rails.root.to_s : Dir.pwd
      end

    end
  end
end
