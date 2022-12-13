require_relative "wikimedia_image"

module Onebox
  module Engine
    module MusicBrainz
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

      def request_json(url)
        ::MultiJson.load(URI.open(url,
          "User-Agent" => "discourse-musicbrainz-onebox",
          :read_timeout => timeout
          ))
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
        @data[:area] = raw["area"]["name"] if raw["area"]
      end

      def life_span
        if raw["life-span"] && (raw["life-span"]["begin"] || raw["life-span"]["ended"])
          @data[:begin] = raw["life-span"]["begin"]
          @data[:begin] = "????" if !@data[:begin]
          @data[:end] = raw["life-span"]["end"]

          if !@data[:end] && raw["life-span"]["ended"]
            @data[:end] = "????"
          end

          @data[:lifespan] = @data[:begin]
          if @data[:end]
            @data[:lifespan] += "– #{@data[:end]}"
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
          @data[:image] = wikimedia_image_url(image["url"]["resource"])
          @data[:image_source_label] = "image source"
          if !@data[:image].nil?
            @data[:image_source] = image["url"]["resource"]
            @data[:image_source_label] = "Wikimedia"
          elsif !image["url"]["resource"].empty? && SiteSetting.musicbrainz_load_other_images
            image_url = image["url"]["resource"]
            @data[:image] = image_url
            @data[:image_source] = image_url
            @data[:image_source_label] = URI.parse(image_url).host.downcase
          end
        end
      end

      def wikidata()
        return nil if !wikidata_allowed
        wikidata = get_relations("url", ["wikidata"]).first
        return nil if wikidata.nil?
        url = wikidata["url"]["resource"]
        data = wikidata_data(url)
        if SiteSetting.musicbrainz_show_wikipedia_link
          wiki = data["sitelinks"]["enwiki"]
          if wiki
            add_external_link(
              :url => wiki["url"],
              :icon => "wikipedia.png",
              :title => wiki["title"],
              :alt => "W",
            )
          end
        end

        if SiteSetting.musicbrainz_load_wikimedia_images
          wikidata_image(url, data, WIKIDATA_TYPE_IMAGE) if @data[:image].nil?
          wikidata_image(url, data, WIKIDATA_TYPE_LOGO_IMAGE) if @data[:image].nil?
        end
      end

      def wikidata_image(url, data, type)
        @data[:image] = wikidata_image_url(data, type)
        if !@data[:image].nil?
          @data[:image_source] = url
          @data[:image_source_label] = "Wikidata"
        end
      end

      def wikidata_allowed
        SiteSetting.musicbrainz_show_wikipedia_link || SiteSetting.musicbrainz_load_wikimedia_images
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
      def get_relations(targetEntity, types, direction=nil)
        return [] if !raw["relations"]

        return raw["relations"].select do |rel|
          rel["target-type"] == targetEntity &&
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
