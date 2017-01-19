class Command
  class Option
    attr_reader *%i[
      default
      description
      flags
      long
      short
    ]

    def initialize long, short, description, *flags, &default
      @default     = default
      @description = description
      @flags       = flags
      @long        = make_key long
      @short       = make_key short
    end

    def value_from parsed_options
      data = []

      data.concat parsed_options[:long][long] \
        if parsed_options[:long].key? long

      data.concat parsed_options[:short][short] \
        if parsed_options[:short].key? short

      data = default.call \
        if data.empty?

      data = !! data if flags.include? :boolean

      data
    end

    def is? name
      key = make_key name

      long == key || short == key
    end

    private

    def make_key value
      value
        .to_s
        .downcase
        .to_sym
    end
  end
end
