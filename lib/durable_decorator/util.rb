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
          :sha => method_sha(method) 
        }
      end

      def method_sha method
        Digest::SHA1.hexdigest(method.source.gsub(/\s+/, ' '))
      end

      def logger
        return @logger if @logger

        @logger = Logging.logger(STDOUT)
        @logger.level = :warn
        @logger
      end
    end
  end
end
