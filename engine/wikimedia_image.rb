module Onebox
  module Mixins
    module WikimediaImage
      private

      WIKIMEDIA_URL_REGEX = /^https?:\/\/commons\.wikimedia\.org\/wiki\/(?<name>File:.+)/
      WIKIDATA_URL_REGEX = /^https?:\/\/www\.wikidata\.org\/wiki\/(?<id>Q[0-9]+)/

      WIKIDATA_TYPE_IMAGE = "P18"
      WIKIDATA_TYPE_LOGO_IMAGE = "P154"

      def wikimedia_image_url(url)
        return nil if !SiteSetting.musicbrainz_load_wikimedia_images
        begin
          name = wikimedia_image_name(url)
          return nil if name.nil?
          return load_wikimedia_image(name)
        rescue Exception => e
          Rails.logger.error e.message
          return nil
        end
      end

      def wikimedia_image_api_url(name)
        "https://en.wikipedia.org/w/api.php?action=query&titles=#{name}&prop=imageinfo&iilimit=50&iiprop=timestamp|user|url&iiurlwidth=500&format=json"
      end

      def wikimedia_image_name(url)
        match ||= url.match(WIKIMEDIA_URL_REGEX)
        return match[:name] if match
      end

      def wikidata_image_url(url, type=WIKIDATA_TYPE_IMAGE)
        return nil if !SiteSetting.musicbrainz_load_wikimedia_images
        begin
          id = wikidata_id(url)
          return nil if id.nil?
          api_url = wikidata_api_url(id)
          result ||= ::MultiJson.load(URI.open(api_url,
            "User-Agent" => "discourse-musicbrainz-onebox",
            :read_timeout => timeout))
          entity = result["entities"][id]
          return nil if entity.nil?
          images = entity["claims"][type]
          return nil if images.nil? || images.empty?
          first_image = images.find do |i|
            i["mainsnak"]["datatype"] = "commonsMedia"
          end
          return nil if first_image.nil?
          name = first_image["mainsnak"]["datavalue"]["value"]
          return load_wikimedia_image("File:" + name.gsub(/\s/, "_"))
        rescue Exception => e
          Rails.logger.error e.message
          return nil
        end
      end

      def wikidata_api_url(id)
        "https://www.wikidata.org/wiki/Special:EntityData/#{id}.json"
      end

      def wikidata_id(url)
        match ||= url.match(WIKIDATA_URL_REGEX)
        return match[:id] if match
      end

      private

      def load_wikimedia_image(name)
        api_url = wikimedia_image_api_url(name)
        result ||= ::MultiJson.load(URI.open(api_url,
          "User-Agent" => "discourse-musicbrainz-onebox",
          :read_timeout => timeout))
        pages = result["query"]["pages"]
        return pages.first[1]["imageinfo"].first["url"]
      end
    end
  end
end
