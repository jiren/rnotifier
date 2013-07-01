class RnotifierGenerator < Rails::Generators::Base

	source_root File.expand_path('../templates', __FILE__)  
	class_option :api_key, :aliases => '-k', :type => :string, :desc => 'Rnotifier API key.'

	def add_config
		if options[:api_key]
			template 'initializer.rb', 'config/initializers/rnotifier.rb'
		else
		  p 'Set option --api-key or -k.'
		end
	end

	private
	def api_key
		"'#{options[:api_key]}'"
	end

end

