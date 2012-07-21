require 'taglib'
require 'pp'
require 'FileUtils'


outputDir = "/Volumes/RATATOSK/Dump"
inputDir = "/Volumes/Media/MusicAll/Songbird Library"
@albumMap = {}
@otherFiles = []
@doWork = ARGV[0] == "true"
@ODDITIES = "__otherFiles"


# a hack to figure out which disc we are on
@discCount = 1
@lastAlbum = "NOTANALBUM"

if not outputDir.end_with?("/")
  outputDir += "/"
end

def copyFile(file, folder)
  filePath = folder
  filePath += "/" if not filePath.end_with? "/"
  lastBit = file.rindex("/")
  
  if (lastBit >= 0)
    filePath += file[lastBit+1, file.length]
  else
    filePath += file
  end

  if not File::directory?(folder)
    FileUtils.mkpath folder
  end

  tail = 1
  newFilePath = filePath
  
  while File::exists?( newFilePath)
    tail += 1
    newFilePath = filePath + "_" + tail.to_s
  end

  filePath = newFilePath
  puts "copying from #{file} to #{newFilePath}"
  FileUtils.copy(file, newFilePath) if @doWork
end


def getFiles(dir)
  if not dir.end_with?("/")
    dir += "/"
  end

  return Dir.glob(dir+"**/*").sort
end

def readTag(inFile)   
  TagLib::FileRef.open(inFile) do |file|
    tag = file.tag

    if not tag
      puts "failed on file #{inFile}"
      return
    end

    album = tag.album || "UNKNOWN"
    album.strip!
    @albumMap[album] ||= []

    # figure out what disc we are (assumes lexicographic ordering of input files)
    @discCount = 1 if @lastAlbum != album
    @lastAlbum = album
    trackCount = 1

    for track in @albumMap[album]
      trackCount += 1 if track[:track] == tag.track
    end

    @discCount = [@discCount, trackCount].max

    @albumMap[album].push(
      {
        file: inFile,
        track: tag.track,
        artist: tag.artist || "UNKNOWN",
        disc: @discCount
      }
    )

    return tag
  end  # File is automatically closed at block end
end

def ends_with_any(string, *endings)
  for ending in endings
    return true if string.end_with? ending
  end

  return false
end

def get_mode(strings)
  strings.group_by do |e|
    e
  end.values.max_by(&:size).first
end

allFiles = getFiles(inputDir)
puts "found #{allFiles.length} files"

if not File::directory?(outputDir)
  dir = Dir.mkdir outputDir
else
  dir = Dir.open outputDir
end

for f in allFiles
  if not File::directory?(f)
    if ends_with_any(f, ".mp3", ".m4a", ".m4p", ".flac", ".ogg", ".aiff")
      readTag(f)
    else
      @otherFiles.push(f)
    end
  end
end

@albumMap.each do |album, tracks|
  next if album == "UNKNOWN"

  artistNames = []
  maxDisc = 1

  for track in tracks
    artistNames.push(track[:artist])
    maxDisc = [maxDisc, track[:disc]].max
  end

  artistName = get_mode(artistNames).strip
  artistName = "UNKNOWN" if artistName.empty?
  folderName = artistName + " - " + album
  outputFolderName = outputDir + folderName + "/"

  # move each track into the designated folder
  for track in tracks
    fullOutputFolder = outputFolderName

    if maxDisc > 1
      fullOutputFolder += "Disc #{track[:disc]}/"
    end

    fullOutputFolder = fullOutputFolder.gsub(/[^0-9A-Za-z _!\.\-\/]/, '')
    fullOutputFolder = fullOutputFolder[0,fullOutputFolder.size-1] if fullOutputFolder.end_with? "/"
    
    puts "copying #{track[:file]} to #{fullOutputFolder}"
    copyFile(track[:file], fullOutputFolder)
  end
end

# write unknowns
puts "\n\ncopying unidentified files"
path = outputDir + "__UNKNOWN"

for track in @albumMap["UNKNOWN"]
  copyFile(track[:file], path)
end

puts "\n\ncopying odd files..."
path = outputDir + @ODDITIES

@otherFiles.each do |x|
  puts "copying #{x}"  
  copyFile(x, path)
end