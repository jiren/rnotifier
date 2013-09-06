module Rnotifier
  class Config
    DEFAULT = {
      :api_host     => 'http://api.rnotifier.com',
      :api_version  => 'v1', 
      :exception_path  => 'exception',
      :event_path   => 'event',
      :ignore_env   => %w(development test cucumber selenium),
      :http_open_timeout => 2,
      :http_read_timeout => 4
    }

    CLIENT = "RRG:#{Rnotifier::VERSION}"

    class << self
      attr_accessor :api_key, :environments, :current_env, :app_env, :api_host, :capture_code, :valid
      attr_accessor :ignore_bots, :ignore_exceptions
      attr_accessor :exception_path, :event_path, :benchmake_path

      def [](val)
        DEFAULT[val]
      end

      def init
        Rlogger.init
        self.valid = false

        return unless self.init_env && self.init_api_options

        self.init_igonore_options
        self.app_env = get_app_env
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
            :version => "#{(RUBY_VERSION rescue '')}-p#{(RUBY_PATCHLEVEL rescue '')}",
            :platform =>  (RUBY_PLATFORM rescue ''),
            :ruby_path => Gem.ruby,
            :gem_path => Gem.path
          },
          :timezone => (Time.now.zone rescue nil)
        }
      end

      def app_root
        (defined?(Rails) && Rails.respond_to?(:root)) ? Rails.root.to_s : Dir.pwd
      end

      def init_notifier
        Notifier.init
      end
      
      def init_env
        self.current_env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development' 
        self.environments ||= []

        if self.environments.is_a?(String)
          self.environments = self.environments.to_s.split(',').collect(&:strip)
        end

        return true if self.environments.include?(self.current_env)
        

        #Check for ignore env
        if DEFAULT[:ignore_env].include?(self.current_env) && !self.environments.include?(self.current_env) 
          return false
        end

        true
      end

      def init_igonore_options
        [:ignore_exceptions, :ignore_bots].each do |f|
          value = self.send(f)
          self.send("#{f}=", value.split(',').map(&:strip)) if value && value.is_a?(String)
        end
      end

      def init_api_options
        self.api_key ||= ENV['RNOTIFIER_API_KEY']
        return false if self.api_key.to_s.strip.empty?

        self.api_host ||= DEFAULT[:api_host]

        [:exception_path, :event_path, :benchmake_path].each do |path|
          self.send("#{path}=", "/#{DEFAULT[:api_version]}/#{DEFAULT[path]}")
        end
      end

    end
  end
end
