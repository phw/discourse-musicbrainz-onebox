# name: musicbrainz-onebox
# about: OneBox preview for MusicBrainz.org
# version: 0.12
# authors: Philipp Wolfer <ph.wolfer@gmail.com>
# url: https://github.com/phw/discourse-musicbrainz-onebox

require 'onebox'

require_relative 'engine/musicbrainz_area_onebox'
require_relative 'engine/musicbrainz_artist_onebox'
require_relative 'engine/musicbrainz_discid_onebox'
require_relative 'engine/musicbrainz_event_onebox'
require_relative 'engine/musicbrainz_instrument_onebox'
require_relative 'engine/musicbrainz_label_onebox'
require_relative 'engine/musicbrainz_place_onebox'
require_relative 'engine/musicbrainz_recording_onebox'
require_relative 'engine/musicbrainz_release_onebox'
require_relative 'engine/musicbrainz_releasegroup_onebox'
require_relative 'engine/musicbrainz_series_onebox'
require_relative 'engine/musicbrainz_work_onebox'

enabled_site_setting :musicbrainz_load_wikimedia_images

register_asset "stylesheets/musicbrainz.scss"

Onebox.options.load_paths.push(File.join(File.dirname(__FILE__), "templates"))
