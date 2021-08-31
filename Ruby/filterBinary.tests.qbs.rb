#!/usr/bin/env ruby

require "unicode/categories"

print(Unicode::Categories.categories("A 2"))
print("\n")

content=File.read('voicePackageUrlMap.json')
print(Unicode::Categories.categories(content))
print("\n")

controlCharacters=content.scan(/\p{Cc}+/)
print(controlCharacters)
print("\n")


print(content)
print("\n")

filtered=content.gsub(/\p{Cc}+/) { |w|  '' }
print(filtered)
print("\n")

filteredFile=File.open('voicePackageUrlMap.json.filtered', 'w')
filteredFile.write(filtered)
filteredFile.close
