#/usr/bin/ruby


class Gaps

  ####################################################################
  ###############################INITIALIZE###########################
  ####################################################################
  ####################################################################

  def check_installed()
    devices = device_ids
    devices.each do |phone|
      packages = `adb -d -s #{phone} shell pm list packages -e example.so`.chomp
      if !packages.include?("package:com.example.so")
        puts "\nINSTALLING CLIENT ON DEVICE. DO NOT DISCONNECT!!!\n"
        `adb -d -s #{phone} install -r bin/na.apk`
      end
    end
  end

  def device_ids()
    ids = `adb -d devices`
    ids = ids.split("\n")
    ids = ids - [ids[0]]
    ids.map! {|i| i.sub("\tdevice", "")}
    ids
  end

  def initialize
    ##CHECK IF APK IS INSTALLED
    check_installed

    #No of devices connected
    adb_devices = `./bin/adb devices`
    adb_devices = adb_devices.split("\n")
    @@count = adb_devices.count-1

    #get IMEI of device
    @@imei = `adb shell dumpsys iphonesubinfo`.split("\r\n")[2].split(" ")[3] if @@count==1
    #puts imei
  end

  ####################################################################
  ###############################SYNC#################################
  ####################################################################
  ####################################################################

  def synchronize
    devices = device_ids
    case @@count
    when 0
      puts "\nERROR: No Device Connected!\n"
      exit
    when 3..100
      puts "\nERROR: Multiple Devices Connected!\n"

    when 2
      puts "2 devices found! Do you want to sync them? [y/N]"
      ch = STDIN.gets.chomp
      case ch
      when "y"||"Y"
        phone1_file = "GAPS/phone1.xml"
        phone2_file = "GAPS/phone2.xml"

        #PULL both files
        pull_both_files(phone1_file, phone2_file)

        #Push Union
        union = xml_to_array(phone1_file) | xml_to_array(phone2_file)
        array_to_file(union)
        puts "PUSHING FILE TO BOTH DEVICES"
        `adb -d -s #{devices[0]} push GAPS/union.xml /mnt/sdcard/backup.xml`
        `adb -d -s #{devices[1]} push GAPS/union.xml /mnt/sdcard/backup.xml`

        puts "Calling PUSH"
        `adb -d -s #{devices[0]} shell am start -n com.example.so/.Push_sms`
        `adb -d -s #{devices[1]} shell am start -n com.example.so/.Push_sms`

        puts "REMOVING TEMP FILES"
        sleep(2)
        `rm #{phone1_file}`
        `rm #{phone2_file}`
        puts "..."
        sleep(1)
        `adb -d -s #{devices[0]} shell rm /mnt/sdcard/backup.xml`
        `adb -d -s #{devices[1]} shell rm /mnt/sdcard/backup.xml`
        puts "SYNC SUCCESFULLY!"
      else
        exit
      end


    else
      ##ACTUAL SYNC CODE##
      path = "./GAPS/#{@@imei}"
      #puts path

      `mkdir -p #{path}` if !File.directory?(path)

      `adb shell am start -n com.example.so/.Toggle_fm`
      `adb shell am start -n com.example.so/.Pull_sms`
      `adb shell am start -n com.example.so/.Toggle_fm`
      puts 'PULLING FILE'
      `adb pull /mnt/sdcard/backup.xml GAPS/.phone_sms.xml`
      `adb shell rm /mnt/sdcard/backup.xml`


      db_file = "GAPS/#{@@imei}/sms_db.xml"
      phone_file = "GAPS/.phone_sms.xml"

      ##NO DB exists for phone
      if !File.exists?(db_file)
        `cp #{phone_file} #{db_file}`
        `rm #{phone_file}`
        puts "COPIED to SERVER. SYNC COMPLETE!!!"
      else
        ##DB exists for phone
        push_union(db_file, phone_file)
      end
      
    end
  end


  def xml_to_array(xml)
    file = File.open(xml).read
    file = file.gsub("<main>\n", "") #Remove initial main tag
    file = file.gsub("\n</main>", "") # Remove End main tag
    file = file.split("</entity>\n") # Split at </entity>
    file.map! {|item|  item = item+"</entity>\n"} # Add </entity> at the end
    file[-1]=file[-1].sub("</entity></entity>", "</entity>")

    file
  end

  def push_union(item1, item2)
    union = xml_to_array(item1) | xml_to_array(item2)
    array_to_file(union)
    puts "PUSHING UNION TO PHONE"
    `adb push GAPS/union.xml /mnt/sdcard/backup.xml`
    #puts "Calling/.Push"
    `adb shell am start -n com.example.so/.Push_sms`

    puts "UPDATING LOCAL DB"
    `mv GAPS/union.xml GAPS/#{@@imei}/sms_db.xml`
    puts "REMOVING temp phone_sms.xml"
    `rm GAPS/.phone_sms.xml`

    puts "PUSHED UNION. SYNC COMPLETE!!!"
  end

  def array_to_file(array)
    array = array.join("")
    array = "<main>\n" + array + "\n</main>"
    File.open("GAPS/union.xml", "wb"){|f| f << array}
  end


  def pull_both_files(ph1, ph2)
    puts devices = device_ids

    #pull file from device 1
    puts "Pulling from device 1"

    `adb -d -s #{devices[0]} shell am start -n com.example.so/.Toggle_fm`
    `adb -d -s #{devices[0]} shell  am start -n com.example.so/.Pull_sms`
    `adb -d -s #{devices[0]} pull /mnt/sdcard/backup.xml #{ph1}`
    `adb -d -s #{devices[0]} shell am start -n com.example.so/.Toggle_fm`
    `adb -d -s #{devices[0]} shell rm /mnt/sdcard/backup.xml`


    #pull file from device 2
    puts "Pulling from device 2"
    `adb -d -s #{devices[1]} shell am start -n com.example.so/.Toggle_fm`
    `adb -d -s #{devices[1]} shell  am start -n com.example.so/.Pull_sms`
    `adb -d -s #{devices[1]} pull /mnt/sdcard/backup.xml #{ph2}`
    `adb -d -s #{devices[1]}  shell am start -n com.example.so/.Toggle_fm`
    `adb -d -s #{devices[1]}  shell rm /mnt/sdcard/backup.xml`

    #puts `ls GAPS`


  end

  ####################################################################
  ###############################BACKUP###############################
  ####################################################################
  ####################################################################
  def backup
    #time_stamp = `date`.gsub(" ","").chomp
    time_stamp = Time.now.strftime("%Y-%m-%d_%I:%M:%S")
    puts "Backup Function called...\n"
    #puts @@count

    case @@count
    when 0
      puts "\nERROR: No Device Connected!\n"
      exit
    when 2..100
      puts "\nERROR: Multiple Devices Connected!\n"
    else
      ##ACTUAL BACKUP CODE##
      path = "./GAPS/#{@@imei}"
      #puts path

      `mkdir -p #{path}` if !File.directory?(path)

      `adb shell am start -n com.example.so/.Toggle_fm`
      `adb shell am start -n com.example.so/.Pull_sms`
      puts "Pulling SMS..."
      sleep(3)
      `adb pull /mnt/sdcard/backup.xml #{path}`
      sleep(0.5)
      `adb shell rm /mnt/sdcard/backup.xml`
      `mv #{path}/backup.xml #{path}/#{time_stamp}.xml`
      `adb shell am start -n com.example.so/.Toggle_fm`
      puts "BACKUP SUCCESFULL!!"
    end

  end
  ####################################################################
  ###############################RESTORE###############################
  ####################################################################
  ####################################################################

  #List all available backups for a device

  def list_available_backups
    if @@count != 1
      puts "O orMultiple devices connected!"
      exit
    end
    list =[]

    list =  `ls GAPS/#{@@imei}`.split("\n") - (["sms_db.xml"])
    #If no file exists then display
    if list.empty?
      puts "\n\n\t\t No existing Databases found!!!\n\n"
      exit
    end

    #List available backup files if they exist in GAPS/IMEI
    #list = ["today", "yesterday", "tomorrow"]
    puts 'These are the available backups'
    list.each_with_index do |item, index|
      print "#{index} #{item} \n"
    end
  end

  def restore(arg)
    case @@count
    when 1
    list =`ls GAPS/#{@@imei}`.split("\n") -["sms_db.xml"]
    #Is arg valid?

    ##LOGIC 1 : BY ID
    if  !( list.count > arg.to_i)
      puts "\nERROR : Invalid arguement"
      exit
    end

    #ARGUEMENT IS VALID
    puts "\t\tWARNING! Restoring will delete previous data!!!\n"
    puts "Continue? [y/N]\n"

    choice = STDIN.gets.chomp

    case choice
    when "y",  "Y"
      puts "PUSHING"
      puts "GAPS/#{@@imei}/#{list[arg.to_i]}"
      `adb push  GAPS/#{@@imei}/#{list[arg.to_i]} /mnt/sdcard/backup.xml`
      `adb shell am start -n com.example.so/.Push_sms`
      sleep(5)
      `adb shell rm /mnt/sdcard/backup.xml`
      puts "RESTORED SUCCESFULLY!"
    else
      exit
    end

    else
      puts "0 or multiple devices connected!"
    end
  end

  def restore_other(arg)
    if !File.exists?(arg)
      puts "File Does Not Exist!!!"
      puts "Sample usage:"
      puts " -O path/to/xml"
      puts " -O GAPS/1234567899/SunMay1216:33:46IST2013.xml"
      puts " -O ~/custom.xml"
      exit

    else
      puts "\t\tWARNING! Restoring will delete previous data!!!\n"
      puts "Continue? [y/N]\n"

      choice = STDIN.gets.chomp
      case choice
      when "y",  "Y"
        puts "RESTORING!"

        `adb push #{arg} /mnt/sdcard/backup.xml`
        `adb shell am start -n com.example.so/.Push_sms`
        sleep(2)
        puts "Restore Success!!"
        sleep(3)
        `adb shell rm /mnt/sdcard/backup.xml`
      else
        exit
      end
    end
  end

  ####################################################################
  ###############################CONTACTS#############################
  ####################################################################
  ###################################################################

  ##BACKUP
  def pull_contacts

    `adb shell am start -n com.example.so/.Toggle_fm`
    sleep(0.5)

    `adb shell am start -n com.example.so/.Pull_contacts`
    sleep(1)

    `adb shell am start -n com.example.so/.Toggle_fm`
    sleep(0.5)
    puts "Pulling contacts!"
    sleep(1)
  end

  def push_contacts
   
    #`adb shell am start -n com.example.so/.Toggle_fm`
    sleep(0.5)

   
    `adb shell am start -n com.example.so/.Push_contacts`
    sleep(1)

   
    #`adb shell am start -n com.example.so/.Toggle_fm`
    sleep(0.5)
    puts "Pushing contacts!"
    sleep(1)
  end

  def backup_contacts
    case @@count
    when 0
      puts "No device connected!!!"

    when 2..100
      puts "Multiple devices connected!!!"

    when 1
      time_stamp = Time.now.strftime("%Y-%m-%d_%I:%M:%S")
      ##Check if directory exists
      path = "GAPS/#{@@imei}/contacts"
      if !File.directory?("#{path}")
        `mkdir -p #{path}`
      end

      ##Call activity
      pull_contacts
      puts "Contact Pull Activity Called"
      #Pull contacts file
      `adb pull /mnt/sdcard/backup_contacts.vcf #{path}`
      #Rename contacts backup
      `mv #{path}/backup_contacts.vcf #{path}/#{time_stamp}.vcf`

      #Delete file from phone
      `adb shell rm /mnt/sdcard/backup_contacts.vcf`
      puts "Contact Backup Succesfull!"

    end


  end

  ##RESTORE
  def list_available_contacts
    case @@count
    when 0
      puts "No devices connected!!"
    when 2..100
      puts "Multiple devices connected!!"
    when 1
      path = "GAPS/#{@@imei}/contacts"
      ##Check if directory exists
      if !File.directory?"#{path}"
        puts "No Backups found for this device!!!"
        break
      end
      ##Populate list of vcf
      list = `ls #{path}`.split("\n")

      if list.empty?
        puts "No Backups found for this device!!!"
        break
      end

      ##Display
      puts "\nAvailable Backups"
      list.each_with_index {|item, index| puts "#{index} \t #{item}"}
    end
  end

  def restore_contacts(arg)
    case @@count
    when 0
      puts "No devices connected!!"
    when 2..100
      puts "Multiple devices connected!!"
    when 1
      
      path = "GAPS/#{@@imei}/contacts"
      ##Populate list of vcf
      list = `ls #{path}`.split("\n")
      
      ##Check if directory exists
      if !File.directory?"#{path}"
        puts "No Backups found for this device!!!"
        break
      end

      ##Check if arguement is valid
      if arg.to_i > list.count-1
        puts "Invalid arguement!"
      else

        ##Push file
        `adb push #{path}/#{list[arg.to_i]} /mnt/sdcard/backup_contacts.vcf`
        puts "Pushed contacts file to device ..."

        #Call push activity
        push_contacts

        #remove contacts file from device
        #`adb shell rm /mnt/sdcard/backup_contacts.vcf`
      end


    end
  end
end

#gaps.new.list_available_backups
