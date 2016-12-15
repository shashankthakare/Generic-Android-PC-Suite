#!/usr/bin/ruby
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

require './lib/enc'
require './lib/gaps'

@encrypto = Encryption.new
class OptparseExample
  @@gaps = Gaps.new

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: example.rb [options]"

      opts.separator ""
      opts.separator "Options:"


      ####SYNC####
      opts.on("-S", "--sync", "Sync device") do
        @@gaps.synchronize
      end

      #####BACKUP#####
      opts.on("-B", "--backup", "Backup device") do
        @@gaps.backup
      end


      #####RESTORE#####
      opts.on("-R", "--restore [ARG]" ,"Restore to previous state. ARG = 0,1,2") do |arg|

        #If no db file specified
        if arg.nil?
          @@gaps.list_available_backups
          exit
        end

        #If db file specified
        #puts "arguement = #{arg}"
        @@gaps.restore(arg)

      end

      ####OTHER_DB_RESTORE
      opts.on("-O", "--other [arg]", "Restore DB from another device.") do |arg|
        if arg.nil?
          puts "NO DB SPECIFIED!!"
          puts "Sample usage:"
          puts " -O path/to/xml"
          puts " -O GAPS/1234567899/SunMay1216:33:46IST2013.xml"
          puts " -O ~/custom.xml"
          exit
        else
          #If db specified
          @@gaps.restore_other(arg)
        end
      end


      ####CONTACTS
      opts.on("-C", "--back-contacts", "Backup contacts") do
        @@gaps.backup_contacts
      end

      opts.on("-c","--restore-contacts [ARG]", "Restore contacts") do |arg|
        if arg.nil?
          @@gaps.list_available_contacts
        else
          @@gaps.restore_contacts(arg)
        end
      end

      ###ENCRYPT/DECRYPT
      opts.on("-D", "--decrypt ARG", "Decrypt file") do |arg|
        if File.dirname(arg).include?"GAPS"
          `cp #{arg.chomp(".enc")} .`
        else
          `openssl aes-256-cbc -a -d -pass pass:p  -in #{arg} -out ./#{File.basename(arg).chomp(".enc")} `
        puts "File decrypted in current directory!"
        end
      end

      opts.on("-E", "--encrypt ARG") do |arg|
        `openssl aes-256-cbc -a -pass pass:p -salt -in #{arg} -out ./#{File.basename(arg)}.enc `
      end

      
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end



    end

    opts.parse(args)
    options
  end  # parse()

end  # class OptparseExample

ARGV << "-h" if ARGV.empty?

@encrypto.decrypt_dir("GAPS")
OptparseExample.parse(ARGV)
@encrypto.encrypt_dir("GAPS")
#pp options
