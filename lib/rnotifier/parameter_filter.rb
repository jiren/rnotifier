module Rnotifier
  class ParameterFilter

    DEFAULT_FIELDS = [:password, :password_confirmation, :authorization, :secret, :passwd]
    FILTERED = '[FILTERED]'

    def self.filter(params, filters)
      @filter ||= ParameterFilter.new(filters)
      @filter.filter(params)
    end

    def self.default_filter(params)
      @default_filter ||= ParameterFilter.new(DEFAULT_FIELDS)
      @default_filter.filter(params)
    end

    def initialize(filters)
      @filters = filters
    end

    def filter(params)
      if @filters && !@filters.empty?
        compiled_filter.call(params)
      else
        params
      end
    end

    private

    def compiled_filter
      @compiled_filter ||= begin
      regexps, blocks = compile_filter

        lambda do |original_params|
          filtered_params = {}

          original_params.each do |key, value|
            if regexps.find { |r| key =~ r }
              value = FILTERED
            elsif value.is_a?(Hash)
              value = filter(value)
            elsif value.is_a?(Array)
              value = value.map { |v| v.is_a?(Hash) ? filter(v) : v }
            elsif blocks
              key = key.dup
              value = value.dup rescue value 
              blocks.each { |b| b.call(key, value) }
            end

            filtered_params[key] = value
          end

          filtered_params
        end
      end
    end

    def compile_filter
      strings, regexps, blocks = [], [], []

      @filters.each do |item|
        case item
        when NilClass
        when Proc
          blocks << item
        when Regexp
          regexps << item
        else
          strings << item.to_s
        end
      end

      regexps << Regexp.new(strings.join('|'), true) unless strings.empty?
      [regexps, blocks]
    end
  end
end
