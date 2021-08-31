#!/usr/bin/env ruby

# encoding: utf-8

this_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(this_dir) unless $LOAD_PATH.include?(this_dir)

require 'bunny'
require 'open-uri'
require 'uri'
require 'get_process_mem'

require File.dirname(__FILE__)+'/VoicePackageMapMessage_pb'

$wholeVoicePackageMap=Hash.new #整个映射。

def mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。
    request=Com::Stupidbeauty::Hxlauncher::VoicePackageMapMessage.new #创建请求对象。
  
    request=Com::Stupidbeauty::Hxlauncher::VoicePackageMapMessage.decode(mapFileContent) #protobuf解码。
    
    request.map.each do |mapItem| #一个个地输出。
        voiceRecognizeResult=mapItem.voiceRecognizeResult #识别结果。
        packageName=mapItem.packageName #包名。
        
#         puts "Voice: #{voiceRecognizeResult}, package: #{packageName}" #输出。
        
#         puts "Whole voice package map before merge: #{$wholeVoicePackageMap}" #报告载入结果。
        
        $wholeVoicePackageMap[voiceRecognizeResult]=mapItem #记录到映射中。
    end #request.map.each do |mapItem| #一个个地输出。

        
    #输出照片文件：
    pictureFileContent=request.pictureFileContent #获取照片文件内容
    
    if (pictureFileContent.empty?) #数据为空
    else #数据不为空

        begin         #写入文件，可能写入失败
            pictureFile=File.new("#{(Time.new.to_f)}.jpg", "w") #照片文件
            
            pictureFile.syswrite(pictureFileContent) #写入内容
            
            pictureFile.close #关闭文件
        rescue  Errno::ENOSPC
            puts("No space left on device. Free some space immediately") #报告错误
        end

    end #if (pictureFileContent.nil?) #数据为空
    
end #def mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。

def serializeWholeVoicePackageMap #将整个映射序列化成字节数组。
    mapMessage=Com::Stupidbeauty::Hxlauncher::VoicePackageMapMessage.new #构造整体映射消息对象。
    
    $wholeVoicePackageMap.each do |voiceRecognizeResult, currentMapItem| #一对对地构造并加入。
#         currentMapItem=Com::Stupidbeauty::Hxlauncher::VoicePackageMapItemMessage.new #构造一个条目。
#         
#         currentMapItem.voiceRecognizeResult=voiceRecognizeResult #设置语音识别结果。
#         currentMapItem.packageName=packageName #设置包名。
        
        mapMessage.map << currentMapItem #加入到映射列表中。
    end #wholeVoicePackageMap.each do |voiceRecognizeResult, packageName| #一对对地构造并加入。
    
    serializeResult=Com::Stupidbeauty::Hxlauncher::VoicePackageMapMessage.encode(mapMessage) #编码。
end #def serializeWholeVoicePackageMap #将整个映射序列化成字节数组。

#载入整个映射。
def loadWholeVoicePackageMap
    if (File.exists?("voiceShortMap.ost")) #文件存在．
        attachementFile=File.new("voiceShortMap.ost", "r") #创建附件图片文件。
        mapFileContent=attachementFile.read #全部读取。
        attachementFile.close #关闭文件。

        mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。
    end #if (File.exists?("voiceShortMap.ost")) #文件存在．
    
    puts "Whole voice package map loaded: #{$wholeVoicePackageMap}" #报告载入结果。
end #def loadWholeVoicePackageMap #载入整个映射。

loadWholeVoicePackageMap #载入整个映射。

puts "Whole voice package map before subscribe: #{$wholeVoicePackageMap}" #报告载入结果。

connectionString =  "connection string hidden intentially" #连接字符串
conn=Bunny.new(connectionString) #创建连接。

conn.start

puts "Connected to host:"+conn.hostname #报告主机名字。

ch=conn.create_channel

q=ch.queue("com.stupidbeauty.hxlauncher.VoiceShortcutAssociationDataQueue", :durable=>true) #声明队列．

ch.prefetch(1)

puts " [*] Waiting for messages in #{q.name}. To exit press CTRL+C"

puts "Whole voice package map before subscribe: #{$wholeVoicePackageMap}" #报告载入结果。

q.subscribe(:manual_ack=>true,:block => true) do | delivery_info,properties,body|
    mergeToWholeVoicePackageMap(body) #合并到整个映射中。

    serializedBody=serializeWholeVoicePackageMap #将整个映射序列化成字节数组。

    begin #写入文件，可能写入失败
        attachementFile=File.new("voiceShortMap.ost","w") #创建附件图片文件。
        attachementFile.syswrite(serializedBody) #保存附件图片。
        attachementFile.close #关闭文件。
        
    rescue  Errno::ENOSPC
        puts("No space left on device. Free some space immediately") #报告错误
    end

    ch.ack(delivery_info.delivery_tag)        #确认。
    
    puts "Sent ack. Now: #{Time.now}" #报告，已经发送ACK。
    
    mem= GetProcessMem.new
    
    puts("Memory: #{mem.gb}"); #Debug
    
    if (mem.gb>=3) #使用太多内存
        puts("Use too much memory. Should quit"); #报告问题
        
        exit(true) #退出
    end #if (mem.gb>=3) #使用太多内存
end
