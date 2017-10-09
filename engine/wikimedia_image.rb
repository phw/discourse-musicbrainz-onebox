module Onebox
  module Mixins
    module WikimediaImage
      private

      URL_REGEX = /^https?:\/\/commons\.wikimedia\.org\/wiki\/(?<name>File:.+)/

      def wikimedia_image_api_url(name)
        "https://en.wikipedia.org/w/api.php?action=query&titles=#{name}&prop=imageinfo&iilimit=50&iiprop=timestamp|user|url&iiurlwidth=500&format=json"
      end

      def wikimedia_image_url(url)
        return nil if !SiteSetting.musicbrainz_load_wikimedia_images
        begin
          name = wikimedia_image_name(url)
          return nil if name.nil?
          api_url = wikimedia_image_api_url(name)
          result ||= ::MultiJson.load(open(api_url,
            "User-Agent" => "discourse-musicbrainz-onebox",
            :read_timeout => timeout))
          pages = result["query"]["pages"]
          return pages.first[1]["imageinfo"].first["url"]
        rescue Exception => e
          Rails.logger.error e.message
          return nil
        end
      end

      def wikimedia_image_name(url)
        match ||= url.match(URL_REGEX)
        return match[:name] if match
      end
    end
  end
end
