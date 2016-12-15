#!/usr/bin/ruby

def xml_to_array(xml)
  file = File.open(xml, 'r').read
  file = file.gsub("<main>\n", "") #Remove initial main tag
  file = file.gsub("\n</main>", "") # Remove End main tag
  file = file.split("</entity>\n") # Split at </entity>
  file.map! {|item|  item = item+"</entity>\n"} # Add </entity> at the end
  file[-1]=file[-1].sub("</entity></entity>", "</entity>")

  file
end

def array_to_file(array)
  array = array.join("")
  array = "<main>\n" + array + "\n</main>"
  
end

puts "\n\nPHONE"
phone = xml_to_array("../GAPS/tmp/phone.xml")
phone.each {|i| p i}
puts ("sms count = #{phone.count}")



puts "\n\nDB"
db = xml_to_array("../GAPS/tmp/db.xml")
db.each {|i| p i}
puts ("sms count = #{db.count}")

puts ("\n\n")

puts "\n\nUNION"
union =phone | db
#puts union
union.each {|i| p i}
puts union.count

p array_to_file(union)
puts array_to_file(union)

op = File.open('union.xml', 'wb')
op << array_to_file(union)
op.close
