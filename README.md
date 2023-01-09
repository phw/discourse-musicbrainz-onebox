# Discourse MusicBrainz Onebox plugin

This plugin adds Onebox support for [MusicBrainz.org](https://musicbrainz.org) to [Discourse](https://www.discourse.org/).
Use it to quickly display information about artists, releases, labels and more.

This plugin is primarily used in the [MetaBrainz Community](https://community.metabrainz.org/) forums.


## Supported entities

- [x] Artists
- [x] Release Groups
- [x] Releases
- [x] Works
- [x] Recordings
- [x] Labels
- [x] Places
- [x] Events
- [x] Series
- [x] Instruments
- [x] Areas
- [x] DiscIDs
- [x] Public collections


## Installation

Please follow this official [plugin installation how-to](https://meta.discourse.org/t/install-a-plugin/19157). Use `https://github.com/phw/discourse-musicbrainz-onebox.git` as the git clone URL.


## Settings

You can configure the MusicBrainz oneboxes in the Discourse admin interface. The following options are available:

**musicbrainz load caa images**: Enable, to load images for releases and release groups from [Cover Art Archive](https://coverartarchive.org/). Default: enabled.

**musicbrainz load wikimedia images**: Enable, to load images from [Wikimedia Commons](https://commons.wikimedia.org/wiki/Main_Page). This requires the MusicBrainz entity to either have a link to an image on Wikimedia or have a [Wikidata](https://www.wikidata.org/) entry. Default: enabled.

**musicbrainz load other images**: Enable, to load images from other sources. This requires the MusicBrainz entity to link to an external image with a URL relationship. This is currently mainly used
by label logos and for some instruments. Default: enabled.

**musicbrainz show wikipedia link**: Show a link to the item's Wikipedia page. This requires the MusicBrainz entity to be linked to Wikidata. Default: enabled.

**musicbrainz genre limit**: If a onebox shows the genres associated with the linked MusicBrainz entity, this setting limits the number of genres shown. Default: 5.


## License

Discourse MusicBrainz Onebox plugin © 2016-2023 Philipp Wolfer <ph.wolfer@gmail.com>

Published under the MIT license, see LICENSE.txt for details.
