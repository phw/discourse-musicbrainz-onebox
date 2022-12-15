require "cgi"
require_relative "request_helper"

module Onebox
  module Mixins
    module WikimediaImage
      include Onebox::Mixins::JsonRequestHelper

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

      def wikidata_data(url)
        id = wikidata_id(url)
        return nil if id.nil?
        api_url = wikidata_api_url(id)
        result ||= request_json(api_url)
        result.dig("entities", id) if !result.nil?
      end

      def wikidata_image_url(data, type=WIKIDATA_TYPE_IMAGE)
        return nil if !SiteSetting.musicbrainz_load_wikimedia_images
        return nil if data.nil?
        begin
          images = data.dig("claims", type)
          return nil if images.nil?
          first_image = images.find do |i|
            i.dig("mainsnak", "datatype") == "commonsMedia"
          end
          return nil if first_image.nil?
          name = first_image.dig("mainsnak", "datavalue", "value")
          return load_wikimedia_image(wikimedia_file_name(name))
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

      def load_wikimedia_image(name)
        api_url = wikimedia_image_api_url(name)
        result ||= request_json(api_url)
        page = result.dig("query", "pages")&.first&.[](1)
        return page["imageinfo"]&.first&.dig("url")
      end

      def wikimedia_file_name(name)
        "File:" + CGI.escape(name.gsub(/\s/, "_"))
      end
    end
  end
end
