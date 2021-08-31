#!/usr/bin/env ruby

# encoding: utf-8

this_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(this_dir) unless $LOAD_PATH.include?(this_dir)

require 'bunny'
require 'open-uri'
require 'uri'
require File.dirname(__FILE__)+'/VoicePackageMapMessage_pb'

$wholeVoicePackageMap=Hash.new #整个映射。

$entryAmount=0 #条目个数

def mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。
    request=Com::Stupidbeauty::Hxlauncher::VoicePackageMapMessage.new #创建请求对象。
  
    request=Com::Stupidbeauty::Hxlauncher::VoicePackageMapMessage.decode(mapFileContent) #protobuf解码。
    
    attachementFile=File.new("voicePackageNameMap.EM.cx", "w") #创建附件图片文件。
    
    
    request.map.each do |mapItem| #一个个地输出。
        voiceRecognizeResult=mapItem.voiceRecognizeResult #识别结果。
        
        applicationInformationList=mapItem.applicationInformation #获取应用程序信息列表
        
        applicationInformationList.each do |currentApplicationInfo| #一个个地遍历
            packageName=currentApplicationInfo.packageName #包名。
            activityName=currentApplicationInfo.activityName #活动名

            $entryAmount=$entryAmount+1 #计数
            
            puts ("Voice: #{voiceRecognizeResult}, package: #{packageName}, activity: #{activityName}, entry amount: #{$entryAmount}") #输出。
            
            if (voiceRecognizeResult.length < 2) #空白内容或太短
            else
                attachementFile.syswrite("E\n") #输出E行
                attachementFile.syswrite("M #{voiceRecognizeResult}\n") #输出问题行
                attachementFile.syswrite("M #{packageName}\n") #输出答案行
                
            end 
            
            
        end #applicationInformationList.each do |currentApplicationInfo| #一个个地遍历
        puts

        $wholeVoicePackageMap[voiceRecognizeResult]=mapItem #记录到映射中。
    end #request.map.each do |mapItem| #一个个地输出。
    
    attachementFile.close #关闭文件。

end #def mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。

#载入整个映射。
def loadWholeVoicePackageMap
    attachementFile=File.new("voicePackageNameMap.ost", "r") #创建附件图片文件。
    mapFileContent=attachementFile.read #全部读取。
    attachementFile.close #关闭文件。

    mergeToWholeVoicePackageMap(mapFileContent) #合并到整个映射中。
end #def loadWholeVoicePackageMap #载入整个映射。

loadWholeVoicePackageMap #载入整个映射。
