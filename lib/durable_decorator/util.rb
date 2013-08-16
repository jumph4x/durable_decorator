module DurableDecorator
  class Util
    class << self
      def symbolized_hash hash
        chill_hash = {}

        hash.each do |k,v|
          chill_hash[k.to_sym] = v
        end

        chill_hash
      end

      def class_name clazz
        name = clazz.name || ''
        name = clazz.to_s if name.empty?
        name.to_sym
      end

      def full_method_name clazz, method_name
        "#{class_name(clazz)}##{method_name}"
      end

      def method_hash name, method
        {
          :name => name,
          :sha => method_sha(method),
          :body => outdented_method_body(method),
          :source => method.source_location
        }
      end

      def outdented_method_body method
        body = method.source
        indent = body.match(/^\W+/).to_s
        body.lines.map{|l| l.sub(indent, '')}.join
      end

      def method_sha method
        Digest::SHA1.hexdigest(method.source.gsub(/\s+/, ' '))
      end

      def logger
        return @logger if @logger

        Logging.color_scheme( 'bright',
          :levels => {
            :info  => :green,
            :warn  => :yellow,
            :error => :red,
            :fatal => [:white, :on_red]
          }
        )

        Logging.appenders.stdout(
          'stdout',
          :layout => Logging.layouts.pattern(
            :pattern => '%-5l %c: %m\n',
            :color_scheme => 'bright'
          )
        )

        @logger = Logging.logger['DurableDecorator']
        @logger.level = :warn

        Logging.logger.root.appenders = Logging.appenders.stdout
        @logger
      end
    end
  end
end
