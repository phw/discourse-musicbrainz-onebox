require_relative "musicbrainz"

module Onebox
  module Engine
    class MusicBrainzEventOnebox
      include Engine
      include LayoutSupport
      include MusicBrainz

      matches_entity("event")
      always_https

      private

      def url
        "https://#{match[:domain]}/ws/2/#{@@entity}/#{match[:mbid]}?fmt=json&inc=place-rels+artist-rels"
      end

      def match
        @match ||= @url.match(@@matcher)
      end

      def data
        return @data if @data

        @data = {
          link: @url,
          id: raw["id"],
          title: raw["name"],
          type: raw["type"]
        }

        @data[:type] = I18n.t("event.type") if @data[:type].to_s.empty?

        disambiguation
        life_span
        place
        performers
        description

        return @data
      end

      def description
        key = if @data[:place] && @data[:area] && @data[:lifespan]
          "event.description_place_area_date"
        elsif @data[:place] && @data[:area]
          "event.description_place_area"
        elsif @data[:place] && @data[:lifespan]
          "event.description_place_area"
        elsif @data[:place]
          "event.description_place"
        elsif @data[:area] && @data[:lifespan]
          "event.description_area_date"
        elsif @data[:area]
          "event.description_area"
        elsif @data[:lifespan]
          "event.description_date"
        else
          "event.description"
        end
        @data[:description] = I18n.t(key, @data)
      end

      def place
        place_rel = get_relations("place", ["held at"]).first
        if place_rel && place_rel["place"]
          place = place_rel["place"]
          @data[:place] = place["name"]
          @data[:area] = place["area"]["name"] if place["area"]
        end
      end

      def performers
        performer_rels = get_relations("artist", ["main performer"]) +
          get_relations("artist", ["support act"]) +
          get_relations("artist", ["orchestra"]) +
          get_relations("artist", ["guest performer"])
        performers = performer_rels.map { |rel| rel["artist"]["name"] }
        @data[:performers] = I18n.t('event.performers', {
          performers: join_sentence(performers)
        }) if !performers.empty?
      end
    end
  end
end
