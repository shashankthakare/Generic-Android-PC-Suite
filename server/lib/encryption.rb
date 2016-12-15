require 'openssl'
require 'digest/sha1'
cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
cipher.encrypt
# your pass is what is used to encrypt/decrypt
cipher.key = key = Digest::SHA1.hexdigest("11111")

puts f = File.open('foo', 'r').read
encrypted = cipher.update(f)+ cipher.final
#puts "encrypted: #{encrypted}\n"
decipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
decipher.decrypt
decipher.key = key

#decrypted = decipher.update(encrypted) + decipher.final
#puts "decrypted: #{decrypted}\n"

class Encryption
  def initialize
    @@cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    @@cipher.encrypt
    @@cipher.key=key = Digest::SHA1.hexdigest("11111")
    @@decipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    @@decipher.decrypt
    @@decipher.key = key
  end
  
  def encrypt (file)
    if !File.exist?(file)
      puts "File does not exist!"
      exit
    else
      @@cipher.update(file) + @@cipher.final
    end
  end

  def decrypt (file)
    if !File.exist?(file)
      puts "File does not exist!"
      exit
    else
      @@decipher.update(file) + @@decipher.final
    end
  end
end

p "encrypt"
p Encryption.new.encrypt("foo")
p "decrypt"
p Encryption.new.decrypt("foo")
