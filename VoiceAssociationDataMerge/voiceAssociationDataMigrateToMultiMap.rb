#!/usr/bin/env ruby

# encoding: utf-8

this_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(this_dir) unless $LOAD_PATH.include?(this_dir)

require 'bunny'
require 'open-uri'
require 'uri'
require File.dirname(__FILE__)+'/VoicePackageMapMessage_pb'

$wholeVoicePackageMap=Hash.new #整个映射。

def mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。
    request=Com::Stupidbeauty::Hxlauncher::VoicePackageMapMessage.new #创建请求对象。
  
    request=Com::Stupidbeauty::Hxlauncher::VoicePackageMapMessage.decode(mapFileContent) #protobuf解码。
    
    request.map.each do |mapItem| #一个个地输出。
        voiceRecognizeResult=mapItem.voiceRecognizeResult #识别结果。
        packageName=mapItem.packageName #包名。
        packageUrl=mapItem.packageUrl #下载地址
        activityName=mapItem.activityName #活动名字
        shortcutId=mapItem.shortcutId #快捷方式编号
        iconType=mapItem.iconType #图标类型
        
        puts("Voice: #{voiceRecognizeResult}, package: #{packageName}, url: #{packageUrl}, activity: #{activityName}, shortcut: #{shortcutId}, icon type: #{iconType}") #输出。
        
        $wholeVoicePackageMap[voiceRecognizeResult]=mapItem #记录到映射中。
    end #request.map.each do |mapItem| #一个个地输出。

end #def mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。

def serializeWholeVoicePackageMap #将整个映射序列化成字节数组。
    mapMessage=Com::Stupidbeauty::Hxlauncher::VoicePackageMapMessage.new #构造整体映射消息对象。
    
    $wholeVoicePackageMap.each do |voiceRecognizeResult, currentMapItem| #一对对地构造并加入。
#         currentMapItem=Com::Stupidbeauty::Hxlauncher::VoicePackageMapItemMessage.new #构造一个条目。
#         
#         currentMapItem.voiceRecognizeResult=voiceRecognizeResult #设置语音识别结果。
#         currentMapItem.packageName=packageName #设置包名。
#         待续
        
        currentApplicationInformation=Com::Stupidbeauty::Hxlauncher::AndroidApplicationMessage.new  #当前应用程序信息
        currentApplicationInformation.packageName=currentMapItem.packageName #复制包名
        currentApplicationInformation.activityName=currentMapItem.activityName #复制活动名字
#         currentApplicationInformation.iconType=currentMapItem.iconType #复制图标类型
        
        puts("appliction information object: #{currentApplicationInformation}") #Debug
        
        currentMapItem.applicationInformation << currentApplicationInformation #加入列表中
        
        
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
    
#     puts "Whole voice package map loaded: #{$wholeVoicePackageMap}" #报告载入结果。
end #def loadWholeVoicePackageMap #载入整个映射。

loadWholeVoicePackageMap #载入整个映射。
serializedBody=serializeWholeVoicePackageMap #迁移并输出

attachementFile=File.new("voicePackageNameMap.ost.migrate","w") #创建附件图片文件。
attachementFile.syswrite(serializedBody) #保存附件图片。
attachementFile.close #关闭文件。

puts "Data body saved." #报告状态，图片已经保存。


# puts "Whole voice package map before subscribe: #{$wholeVoicePackageMap}" #报告载入结果。
