require "io/console"
require 'net/http'

module Atozgen
  def self.init
    puts "------------------------------------------------------------------------------"
    puts "------------------------------WELCOME ON ATOZGEN------------------------------"
    puts "------------------------------------------------------------------------------"
    puts "\n"

    self.form
  end

protected
  def self.hostname_filed(isretry = false)
    puts "please enter atozgen server hostname* #{"(not allowed empty)" if isretry.eql?(true)}: "
    hostname = STDIN.gets.chomp

    if hostname.empty?

      self.hostname_filed(true)
    else

      return hostname
    end
  end

  def self.deviceid_filed(isretry = false)
    puts "please enter device id* #{"(not allowed empty)" if isretry.eql?(true)}: "
    deviceid = STDIN.gets.chomp

    if deviceid.empty?

      self.deviceid_filed(true)
    else

      return deviceid
    end
  end

  def self.secretkey_filed(isretry = false)
    puts "please enter secret key* #{"(not allowed empty)" if isretry.eql?(true)}: "
    secretkey = STDIN.noecho(&:gets).chomp

    if secretkey.empty?

      self.secretkey_filed(true)
    else

      return secretkey
    end
  end

  def self.answer_filed(hostname, isretry = false)
    puts "are you sure the hostname you entered is '#{hostname}'* #{"(not allowed empty)" if isretry.eql?(true)} ? (y/n)"
    answer = STDIN.gets.chomp

    self.answer_filed(hostname, true) if answer.empty? || !["y", "yes", "n", "no"].include?(answer.downcase)

     if ["n", "no"].include?(answer.downcase)
      puts "\n\n\n\n"

      self.init
    end
  end

  def self.form
    hostname  = self.hostname_filed
    deviceid  = self.deviceid_filed
    secretkey = self.secretkey_filed

    self.answer_filed(hostname, isretry = false)

    if self.validate?(hostname, deviceid, secretkey, (Rails.application.class.parent_name rescue "ATOZGEN"))

      self.record(hostname, deviceid, secretkey)
    else

      puts "\n\n\n\n"
      puts "------------------------------------------------------------------------------"
      puts "invalid access. make sure the hostname, device id, and secret key are correct!"
      puts "------------------------------------------------------------------------------"
      puts "\n"

      self.init
    end
  end

  def self.record(hostname, deviceid, secretkey, filename = "keygen.txt")
    File.open(filename, "w") do |file|
      file.puts hostname
      file.puts deviceid
      file.puts secretkey
    end
  end

  def self.read(filename = "keygen.txt")
    values = []

    File.open(filename, "r") do |file|
      values[0] = file.gets.chomp
      values[1] = file.gets.chomp
      values[2] = file.gets.chomp
    end

    return values
  end

  def self.validate?(hostname, deviceid, secretkey, appname)
    begin
      uri          = URI.parse("#{hostname}/v1/authorize")
      http         = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = false
      headers      = {
                        "Content-Type" => "application/json"
                     }
      request      = Net::HTTP::Post.new(uri, headers)
      request.body =  {
                        deviceid: deviceid,
                        secretkey: secretkey,
                        appname: appname
                      }.to_json
      response     = http.request(request)

      return response.code.eql?("200")
    rescue

      return false
    end
  end
end
