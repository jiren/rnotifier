module Rnotifier
  class ExceptionCode
    class << self

      def get(backtrace)
        return unless backtrace
        filename, line, method = (backtrace.find{|l| l =~ /^#{Config.app_env[:app_root]}/} || backtrace[0]).split(':')
        self.find(filename, line.to_i, 3)
      end

      def find(filename, line_no, wrap_size = 1)
        s_range = [line_no - wrap_size, 1].max - 1
        e_range = line_no + wrap_size - 1
        #s_range, e_range = [ (line_no - wrap_size) > 0 ? line_no - wrap_size : 0, line_no + wrap_size]
        code = [s_range]

        begin
          File.open(filename) do |f|
            f.each_with_index do |line, i|
              code << line if i >= s_range && i <= e_range
              break if i > e_range
            end
          end
        rescue Exception => e
        end
        code
      end
    end

  end
end
