# name: musicbrainz-onebox
# about: OneBox preview for MusicBrainz.org
# version: 0.1.1
# authors: Philipp Wolfer <ph.wolfer@gmail.com>
# url: https://github.com/phw/discourse-musicbrainz-onebox

require_relative 'engine/musicbrainz_artist_onebox'
require_relative 'engine/musicbrainz_label_onebox'
require_relative 'engine/musicbrainz_release_onebox'
require_relative 'engine/musicbrainz_releasegroup_onebox'
require_relative 'engine/musicbrainz_work_onebox'

register_asset "stylesheets/musicbrainz.scss"
register_asset "favicons/musicbrainz.png"

Onebox.options.load_paths.push(File.join(File.dirname(__FILE__), "templates"))
