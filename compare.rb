def getFiles(full, files)
  for f in full
    last = f.rindex("/") + 1
    files.push(f[last,f.size]) if not File::directory?(f)
  end
end

files = []
vOut = Dir.glob("/Volumes/RATATOSK/Dump/**/*")
vIn = Dir.glob("/Volumes/Media/MusicAll/Songbird Library/**/*")
getFiles(vOut, files)

puts "#{files.length} files in songbird"
puts files.sort

puts "\n\n\n------------------------------------------------\n\n\n"

files = []
getFiles(vIn, files)
puts "#{files.length} files in new folder"
puts files.sort