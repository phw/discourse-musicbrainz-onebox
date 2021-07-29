require_relative "musicbrainz"

module Onebox
  module Engine
    class MusicBrainzLabelOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("label")
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=url-rels"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          title: raw["name"],
          type: raw["type"],
        }

        @data[:type] = I18n.t("label.type") if @data[:type].to_s.empty?

        disambiguation
        area
        life_span
        image "logo"
        description

        return @data
      end

      def description
        key = if @data[:area] && @data[:lifespan]
          "label.description_area_date"
        elsif @data[:area]
          "label.description_area"
        elsif @data[:lifespan]
          "label.description_date"
        else
          "label.description"
        end
        @data[:description] = I18n.t(key, @data)
      end
    end
  end
end
