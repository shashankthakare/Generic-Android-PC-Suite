#! /usr/bin/ruby
require 'openssl'

class Encryption
  def encrypt(file)
    `openssl aes-256-cbc -a -pass pass:p -salt -in #{file} -out #{file}.enc`
  end

  def decrypt(file)
    `openssl aes-256-cbc -a -d -pass pass:p -in #{file} -out #{file.chomp(".enc")}`
  end

  def encrypt_dir(dir)
    #puts "Listing files"
    @files = Dir.glob("#{dir}/**/*").select{|i| i.end_with?".xml"} #"
    #puts @files
    @files.each do |f|
      self.encrypt(f)
      `rm -rf #{f}`
    end
  end

  def decrypt_dir(dir)
    @files = Dir.glob("#{dir}/**/*").select{|i| i.end_with?".enc"}#"
    #puts @files
    #puts "decrypting"
    @files.each do |f|
      self.decrypt(f)
      `rm -rf #{f}`
    end
  end
end



#Encryption.new.encrypt("foo")
#Encryption.new.decrypt("foo.enc")
#puts "ENCRYPTING"
#Encryption.new.encrypt_dir("../GAPS")

#puts "DECRYPTING"
#Encryption.new.decrypt_dir("../GAPS")
