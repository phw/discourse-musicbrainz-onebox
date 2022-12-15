require_relative "request_helper"
require_relative "wikimedia_image"

module Onebox
  module Engine
    module MusicBrainz
      include Onebox::Mixins::JsonRequestHelper
      include Onebox::Mixins::WikimediaImage

      # Reimplement JSON mixin with proper user agent
      def raw
        begin
          @raw ||= request_json(url)
        rescue OpenURI::HTTPError => e
          Rails.logger.error "#{e.message}: #{url}"
          raise
        end
      end

      def self.included(object)
        object.extend(ClassMethods)
      end

      private

      # Common data helpers
      def disambiguation
        if !raw["disambiguation"].to_s.empty?
          @data[:disambiguation] = raw["disambiguation"]
        end
      end

      def area
        @data[:area] = raw.dig("area", "name") if raw["area"]
      end

      def life_span
        if raw["life-span"] && (raw.dig("life-span", "begin") || raw.dig("life-span", "ended"))
          @data[:begin] = raw.dig("life-span", "begin")
          @data[:begin] = "????" if !@data[:begin]
          @data[:end] = raw.dig("life-span", "end")

          if !@data[:end] && raw.dig("life-span", "ended")
            @data[:end] = "????"
          end

          @data[:lifespan] = @data[:begin]
          if @data[:end]
            @data[:lifespan] += " – #{@data[:end]}"
          end
        end
      end

      def artist_credits
        if raw["artist-credit"]
          @data[:artist] = raw["artist-credit"].reduce "" do |memo, credits|
            memo += credits["name"]
            memo += credits["joinphrase"] if credits["joinphrase"]
          end
        end
      end

      def genres(entity=nil)
        entity = raw if entity.nil?
        if entity["genres"]
          genres = entity["genres"].sort_by { |g| -g["count"] }.map { |g| g["name"] }
          if !genres.empty?
            @data[:genres] = join_list(genres, SiteSetting.musicbrainz_genre_limit)
          end
        end
      end

      def image(type="image")
        image = get_relations("url", [type]).first
        if image
          @data[:image] = wikimedia_image_url(image.dig("url", "resource"))
          @data[:image_source_label] = "image source"
          if !@data[:image].nil?
            @data[:image_source] = image.dig("url", "resource")
            @data[:image_source_label] = "Wikimedia"
          elsif !image.dig("url", "resource")&.empty? && SiteSetting.musicbrainz_load_other_images
            image_url = image["url"]["resource"]
            @data[:image] = image_url
            @data[:image_source] = image_url
            @data[:image_source_label] = URI.parse(image_url).host.downcase
          end
        end
      end

      def caa_rg_image(rgid)
        return nil if !SiteSetting.musicbrainz_load_caa_images
        coverart_url = nil
        begin
          api_url = "https://coverartarchive.org/release-group/#{rgid}"
          result = request_json(api_url)

          image = result["images"][0] if result["images"]
          if image && image["thumbnails"]
            thumbnails = image["thumbnails"]
            @data[:image] = thumbnails["500"] ||
              thumbnails["large"] ||
              thumbnails["250"] ||
              thumbnails["small"]
            @data[:image_source] = result["release"]
            @data[:image_source_label] = "Cover Art Archive"
          end

        rescue OpenURI::HTTPError => e
          # 404 means the release group does not exist or has no cover art.
          # Everything else is unexpected and logged as an error.
          Rails.logger.error e.message unless e.io.status[0] == "404"
        end

        return coverart_url
      end

      def wikidata(entity=nil)
        entity = raw if entity.nil?
        @wikidata ||= {}
        return @wikidata[entity["id"]] if !@wikidata[entity["id"]].nil?
        return nil if !wikidata_allowed?
        wikidata_rel = get_relations("url", ["wikidata"], entity: entity).first
        return nil if wikidata_rel.nil?
        url = wikidata_rel.dig("url", "resource")
        @wikidata[entity["id"]] = wikidata_data(url)
      end

      def wikidata_wikilink(entity=nil)
        if SiteSetting.musicbrainz_show_wikipedia_link && !@data[:has_wiki_link]
          data = wikidata(entity)
          wiki = data&.dig("sitelinks", "enwiki")
          if wiki
            @data[:has_wiki_link] = true
            add_external_link(
              :url => wiki["url"],
              :icon => "wikipedia.png",
              :title => wiki["title"],
              :alt => "W",
            )
          end
        end
      end

      def wikidata_image(entity=nil)
        if SiteSetting.musicbrainz_load_wikimedia_images
          data = wikidata(entity)
          wikidata_image_type(url, data, WIKIDATA_TYPE_IMAGE) if !@data[:image]
          wikidata_image_type(url, data, WIKIDATA_TYPE_LOGO_IMAGE) if !@data[:image]
        end
      end

      def wikidata_symbol(entity=nil)
        data = wikidata(entity)
        unicode_char = data&.dig("claims", WIKIDATA_TYPE_UNICODE_CHARACTER)&.first
        @data["symbol"] = unicode_char&.dig("mainsnak", "datavalue", "value")
      end

      def wikidata_image_type(url, data, type)
        @data[:image] = wikidata_image_url(data, type)
        if !@data[:image].nil?
          @data[:image_source] = url
          @data[:image_source_label] = "Wikidata"
        end
      end

      def wikidata_allowed?
        (SiteSetting.musicbrainz_show_wikipedia_link && !@data[:has_wiki_link]) ||
        (SiteSetting.musicbrainz_load_wikimedia_images && !@data[:image])
      end

      def add_external_link(link)
        @data[:external_links] = [] if @data[:external_links].nil?
        @data[:external_links].push link
      end

      def add_critiquebrainz_link(id=nil, entity=nil)
        id = @data[:id] if id.nil?
        entity = self.class.entity if entity.nil?
        add_external_link(
          :url => "https://critiquebrainz.org/#{entity}/#{id}",
          :icon => "critiquebrainz.png",
          :title => "CritiqueBrainz",
          :alt => "CB",
        )
      end

      # General helper functions
      def get_relations(target_entity, types, direction: nil, entity: nil)
        entity = raw if entity.nil?
        return [] if !entity["relations"]

        return entity["relations"].select do |rel|
          rel["target-type"] == target_entity &&
            types.include?(rel["type"]) &&
            (direction.nil? || rel["direction"] == direction)
        end
      end

      def join_sentence(arr, limit=5, limit_phrase="others")
        arr = arr.uniq.reject(&:nil?)
        if arr.empty?
          return nil
        elsif arr.length == 1
          return arr[0]
        elsif arr.length > limit
          arr = arr[0..limit-1].push(limit_phrase)
        end
        return "#{arr[0..-2].join(', ')} and #{arr.last}"
      end

      def join_list(arr, limit=nil, limit_phrase="…")
        arr = arr.reject(&:nil?)
        if limit and arr.length > limit
          arr = arr[0..limit-1].push(limit_phrase)
        end
        return arr.join(', ')
      end

      def get_mb_url(entity, mbid)
        "https://#{match[:domain]}/#{entity}/#{mbid}"
      end

      def format_seconds(seconds)
        "%02d:%02d" % [seconds / 60, seconds % 60]
      end

      def format_number(number, thousands_separator="\u202F")
        number.to_s.reverse.scan(/\d{1,3}/).join(thousands_separator).reverse
      end

      module ClassMethods
        def matches_entity(entity)
          class_variable_set :@@entity, entity
          matches_regexp(/^https?:\/\/(?<domain>(?:beta\.)?musicbrainz\.org)\/#{Regexp.escape(entity)}\/(?<mbid>[0-9a-z-]{36})(?!\/(?:edit|open_edits))/)
        end

        def entity
          class_variable_get :@@entity
        end
      end

    end
  end
end
