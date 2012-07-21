Dissatisfied with existing software solutions for dealing with music libraries and the jungle that is the file system,
I decided to start writing some scripts to manually accomplish my organizational goals.

Please note that most of these scripts are written in 'beginner ruby', and worse, in the vague style of a Java developer,
including unabashed use of camelCase.

##ID3Mover.rb
Scans an input directory for audio files, sorts them into folders of "artist - album/disc" and then copies them to an
output folder. Uses [Ruby Taglib](http://www.hakubi.us/ruby-taglib/) to read the ID3 tags from the files. Non audio files
are written out to another folder (covers, extras, etc).

##compare.rb
Writes out the file listings of two folders for comparison with a diff utility. I'm sure there's a unix command for this...