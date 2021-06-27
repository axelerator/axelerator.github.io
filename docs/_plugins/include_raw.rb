# raw_include_relative.rb
module Jekyll
  module Tags
    Escaper = Class.new { include Jekyll::Filters }
    class RawIncludeTag < IncludeTag
      def render(context)
        site = context.registers[:site]

        file = render_variable(context) || @file
        validate_file_name(file)

        path = locate_include_file(context, file, site.safe)
        return unless path

        add_include_to_dependency(site, path, context)

        Escaper.new.xml_escape(read_file(path, context))
      end

    end
  end
end

Liquid::Template.register_tag("raw_include", Jekyll::Tags::RawIncludeTag)
