#!/usr/bin/env ruby

# encoding: utf-8

this_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(this_dir) unless $LOAD_PATH.include?(this_dir)

require 'bunny'
require 'open-uri'
require 'uri'
require File.dirname(__FILE__)+'/VoiceCommandHitDataMessage_pb'


connectionString="connection string hidden intentially" #连接字符串
conn=Bunny.new(connectionString) #创建连接。

conn.start

puts "Connected to host:"+conn.hostname #报告主机名字。

ch=conn.create_channel

q=ch.queue("com.stupidbeauty.hxlauncher.VoiceCommandHitDataQueue",:durable=>true)

ch.prefetch(1)

puts " [*] Waiting for messages in #{q.name}. To exit press CTRL+C"

sentAck=false #尚未发送ACK。

q.subscribe(:manual_ack=>true,:block => true) do | delivery_info,properties,body|
  puts " [x] Received request, length: #{body.length}" #告知已经接收到请求。
  
  request=Com::Stupidbeauty::Hxlauncher::VoiceCommandHitDataMessage.decode(body) #protobuf解码。
  
  print("Voice recognize result: #{request.voiceRecognizeResult}\n") #输出主题。
  print("Package name: #{request.packageName}\n") #输出内容。
  print("Activity name: #{request.activityName}\n") #输出内容。
  print("Icon title: #{request.iconTitle}\n") #输出内容。
  print("Icon type: #{request.iconType}\n") #输出内容。
  
  attachementFile=File.new("asrWavFileContent.wavs","w") #创建附件图片文件。
  attachementFile.syswrite(request.asrWavFileContent) #保存附件图片。
  attachementFile.close #关闭文件。
  
  puts "Attachment image saved." #报告状态，图片已经保存。
  
  if (sentAck) #已经发送过ACK，说明，这是收到的一条新的消息。
    #向STtsServer发送请求，告知收到新消息了：
    puts "Sending request to SttsServer." #报告，在向SttsServer服务器发送请求。
    
    uri=URI.encode('http://192.168.1.101:2005/executeLegacyCommand/?command=BEGIN|A|16|收到新的翻译请求|END') #网址。
    html_response=nil #回复内容。
    
    begin #进行网络访问动作，并且处理可能的异常。
      open(uri) do |http| #发起访问 。
        html_response=http.read #读取回复。
        
        puts "Got response from SttsServer:"+html_response #报告回复内容。
      end #open(uri) do |http| #发起访问 。
    rescue   #处理异常。
    end #begin #进行网络访问动作，并且处理可能的异常。
    
    
    puts html_response #输出回复内容。
    
  end #if (sentAck) #已经发送过ACK，说明，这是收到的一条新的消息。

  
  if (ARGV.empty? ) #未指定命令行参数。
  else #指定了命令行参数。
    if (ARGV[0]=="ack") #要求发送ACK。
      
      if (sentAck) #已经发送ACK。
      else #尚未发送ACK。
        ch.ack(delivery_info.delivery_tag)        #确认。
        
        puts "Sent ack." #报告，已经发送ACK。
        
        sentAck=true #记录，已经发送ACK。
      end #else //尚未发送ACK。
    end #if (ARGV[0]=="ack") #要求发送ACK。
  end #if (ARGV.empty? ) #未指定命令行参数。
end
