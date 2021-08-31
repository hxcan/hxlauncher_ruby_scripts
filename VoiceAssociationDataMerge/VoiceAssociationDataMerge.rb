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
        
        existingMapItem=$wholeVoicePackageMap[voiceRecognizeResult] #获取已有的多映射目标信息对象
        
        if (existingMapItem!=nil) #存在
        else #不存在
            existingMapItem=Com::Stupidbeauty::Hxlauncher::VoicePackageMapItemMessage.new #创建一个
            existingMapItem.voiceRecognizeResult=mapItem.voiceRecognizeResult #复制语音识别结果对象

            $wholeVoicePackageMap[voiceRecognizeResult]=existingMapItem #记录到映射中。
        end #if (existingMapItem!=nil) #存在
        
        puts("merging, voice result: #{voiceRecognizeResult}") #Debug.
        mergeFromExistMapItem(existingMapItem, mapItem) #对于所有的条目，如果不存在，则插入
    end #request.map.each do |mapItem| #一个个地输出。
    
    
    #输出照片文件：
    pictureFileContent=request.pictureFileContent #获取照片文件内容
    
    if (pictureFileContent.empty?) #数据为空
    else #数据不为空
        begin #写入文件，可能写入失败
            pictureFile=File.new("#{(Time.new.to_f)}.jpg", "w") #照片文件
            
            pictureFile.syswrite(pictureFileContent) #写入内容
            
            pictureFile.close #关闭文件
        rescue  Errno::ENOSPC
            puts("No space left on device. Free some space immediately") #报告错误
        end
        
    end #if (pictureFileContent.nil?) #数据为空
    
end #def mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。

 #对于所有的映射目标条目，如果不存在，则插入
def mergeFromExistMapItem(existingMapItem, mapItem)
    packageName=mapItem.packageName #获取已有格式的包名
    activityName=mapItem.activityName #获取已有格式的活动名
    
    if (packageName.empty?) #空白
    else #不空白
        insertIfNotExist(existingMapItem, packageName , activityName) #将包名和活动名插入，不存在则插入
    end #if (packageName.empty?) #空白
    
    
    mapItem.applicationInformation.each do |currentApplicationInformation| #一个个新格式条目地插入，不存在则插入
        
        
        packageName=currentApplicationInformation.packageName #获取已有格式的包名
        activityName=currentApplicationInformation.activityName #获取已有格式的活动名
        
        insertIfNotExist(existingMapItem, packageName , activityName) #将包名和活动名插入，不存在则插入
    end #mapItem.applicationInformation.each do |currentApplicationInformation| #一个个新格式条目地插入，不存在则插入
end #def insertIfNotExist(existingMapItem, mapItem)

 #将包名和活动名插入，不存在则插入
def insertIfNotExist(existingMapItem, packageName , activityName)
    if (packageName.empty?) #包名是空白
    else #不是空白
        exists=false #是否已有存在
        
        existingMapItem.applicationInformation.each do |currentExistingInformation| #一个个地比较
            existingPackageName=currentExistingInformation.packageName #已有包名
            existingActivityName=currentExistingInformation.activityName #已有活动名
            
            if ((existingPackageName==packageName) && (existingActivityName==activityName)) #已存在
                exists=true #存在
                break #跳出，不用再找
            end #if ((existingPackageName==packageName) && (existingActivityName==activityName)) #已存在
        end #existingMapItem.applicationInformation.each do |currentExistingInformation| #一个个地比较
        
        if (exists) #已经存在
        else #不存在
            puts("Inserting non exist, packag: #{packageName}, actiivty: #{activityName}") #Debug
            newApplicationInformation=Com::Stupidbeauty::Hxlauncher::AndroidApplicationMessage.new #创建一个
            newApplicationInformation.packageName=packageName #设置包名
            newApplicationInformation.activityName=activityName #设置活动名
            
            existingMapItem.applicationInformation << newApplicationInformation #加入到列表中
        end #if (exists) #已经存在
        
        
    end #if (packageName.empty?) #包名是空白
    
end #def insertIfNotExist(existingMapItem, packageName , activityName) #将包名和活动名插入，不存在则插入

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
    attachementFile=File.new("voicePackageNameMap.ost", "r") #创建附件图片文件。
    mapFileContent=attachementFile.read #全部读取。
    attachementFile.close #关闭文件。

    mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。
    
    puts "Whole voice package map loaded" #报告载入结果。
end #def loadWholeVoicePackageMap #载入整个映射。

loadWholeVoicePackageMap #载入整个映射。

# puts "Whole voice package map before subscribe: #{$wholeVoicePackageMap}" #报告载入结果。

amqpConnectionString="amqp://ortrherepr:cdgeeefental111329@139.162.164.8:5672"
conn=Bunny.new(amqpConnectionString) #创建连接。

conn.start

puts "Connected to host:"+conn.hostname #报告主机名字。

ch=conn.create_channel

q=ch.queue("com.stupidbeauty.hxlauncher.VoiceAssociationDataQueue", :durable=>true)

ch.prefetch(1)

puts " [*] Waiting for messages in #{q.name}. To exit press CTRL+C"

# puts "Whole voice package map before subscribe: #{$wholeVoicePackageMap}" #报告载入结果。

q.subscribe(:manual_ack=>true,:block => true) do | delivery_info,properties,body|
#     puts " [x] Received request, content: #{body}, length: #{body.length}" #告知已经接收到请求。
    
    messageContentFile=File.new("messageCcontent.messageContnt", "w") #创建文件，用于输出消息内容
    messageContentFile.syswrite(body) #输出
    messageContentFile.close #关闭
  
    begin #处理消息，并捕获异常
    
        mergeToWholeVoicePackageMap(body) #合并到整个映射中。

        serializedBody=serializeWholeVoicePackageMap #将整个映射序列化成字节数组。

        attachementFile=File.new("voicePackageNameMap.ost", "w") #创建附件图片文件。
        attachementFile.syswrite(serializedBody) #保存附件图片。
        attachementFile.close #关闭文件。
        
        puts "Data body saved." #报告状态，图片已经保存。
    rescue Google::Protobuf::ParseError #消息解析出错。消息不完整
        puts("Message content broken") #报告错误
    end #begin #处理消息，并捕获异常
    
  
    ch.ack(delivery_info.delivery_tag) #确认。
    
    puts "Sent ack. Now: #{Time.now}" #报告，已经发送ACK。
    
        mem= GetProcessMem.new
    
    puts("Memory: #{mem.gb}"); #Debug
    
    if (mem.gb>=3) #使用太多内存
        puts("Use too much memory. Should quit"); #报告问题
        
        exit(true) #退出
    end #if (mem.gb>=3) #使用太多内存

end
