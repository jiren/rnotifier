module Rnotifier
  class Config
    DEFAULT = {
      :api_host          => 'http://api.rnotifier.com',
      :api_version       => 'v1', 
      :exception_path    => 'exception',
      :messages_path     => 'event',
      :browser_path      => 'browser',
      :ignore_env        => %w(development test cucumber selenium),
      :http_open_timeout => 2,
      :http_read_timeout => 4
    }

    CLIENT = "RRG:#{Rnotifier::VERSION}"

    class << self
      attr_accessor :api_key, :app_id, :environments, :current_env, :app_env, :api_host, :capture_code, :valid
      attr_accessor :ignore_bots, :ignore_exceptions
      attr_accessor :exception_path, :messages_path, :browser_path

      def [](val)
        DEFAULT[val]
      end

      def []=(field, value)
        self.send("#{field}=", value)
      end

      def init
        Rlogger.init
        self.valid = false

        return unless self.init_env && self.init_api_options

        self.init_igonore_options
        self.app_env = detailed_env
        self.valid = true 
      end

      def valid?
        self.valid
      end

      def app_root
        (defined?(Rails) && Rails.respond_to?(:root)) ? Rails.root.to_s : Dir.pwd
      end

      def init_env
        self.current_env = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development' 
        self.environments ||= []

        if self.environments.is_a?(String)
          self.environments = self.environments.split(',').map(&:strip)
        end

        #Return if config environments not include current env
        return self.environments.include?(self.current_env) unless self.environments.empty?
        
        #Check for ignore env
        !DEFAULT[:ignore_env].include?(self.current_env) 
      end

      def init_igonore_options
        [:ignore_exceptions, :ignore_bots].each do |f|
          value = self.send(f)
          self[f] = value.is_a?(String) ? value.split(',').map(&:strip) : []
        end
      end

      def init_api_options
        self.api_key ||= ENV['RNOTIFIER_API_KEY']
        return false if self.api_key.to_s.strip.empty? || self.app_id.to_s.strip.empty?

        self.api_host ||= DEFAULT[:api_host]

        [:exception_path, :messages_path, :browser_path].each do |path|
          self[path] = "/#{DEFAULT[:api_version]}/#{DEFAULT[path]}"
        end
      end

      def basic_env
        {
          :env => Config.current_env,
          :pid => Process.pid,
          :host => (Socket.gethostname rescue ''),
          :language => 'ruby',
          :time_zone => (Time.now.to_s.split.last rescue nil),
          :client => CLIENT 
        }
      end

      def detailed_env
        basic_env.merge({
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
        })
      end

    end
  end
end
