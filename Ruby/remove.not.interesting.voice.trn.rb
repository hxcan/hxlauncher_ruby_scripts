#!/usr/bin/env ruby

require 'pathname'

def checkOnceMetadata(directoryPath, startIndex=0, layer=0) #打包一个目录树。
    should_remove=false # 是否应当删除
    determined = false # 是否得到确定结论
    
    directoryPathName=Pathname.new(directoryPath) #构造路径名字对象。
    
    baseName=directoryPathName.basename.to_s #基本文件名。
    extName = directoryPathName.extname.to_s # 扩展文件名
    
    if extName == '.metadata' # .metadata 文件名
        #陈欣
                    fileToReadContent=File.new(directoryPath,"rt") # 打开文件。
            currentFileContent=fileToReadContent.read #全部读取

            lines = currentFileContent.split("\n") # 分割成行
            
            lines.select! { |line| line.start_with? 'SEX' }
            
            tabs = lines[0].split "\t" # 分割成单元格
            
            if tabs[1] == 'Male' # Male
                should_remove = true
            end # if tabs[1] == 'Male' # Male
            
            determined = true # 已经得到确定结论
    end # if extName == '.metadata' # .metadata 文件名
    
   [ should_remove, determined ]
end #def downloadOne #下载一个视频。

 # 删除一个目录树。
def remove_directory_content(directoryPath, startIndex=0, layer=0)
    packagedFile={} #创建文件消息对象。
    
    packagedFile['sub_files'] = [] #加入到子文件列表中。
    
    directoryPathName=Pathname.new(directoryPath) #构造路径名字对象。
    
    #directoryPathName.rmdir # 删除
    
    baseName=directoryPathName.basename.to_s #基本文件名。
    
    packagedFile['name']=baseName #设置文件名。
    
    isFile=directoryPathName.file? #是否是文件。
    isSymLink=directoryPathName.symlink? #是否是符号链接
    
    packagedFile['is_file']=isFile #设置属性，是否是文件。
    packagedFile['file_start_index']=startIndex #记录文件内容的开始位置。
    
    packagedFile['is_symlink']=isSymLink #设置属性，是否是符号链接
    
    puts directoryPath #Dbug.
    
    #记录时间戳：
    begin #读取时间戳
        mtimeStamp=File.mtime(directoryPath) #获取时间戳
        
        packagedFile['timestamp']={} #时间戳
        packagedFile['timestamp']['seconds']=mtimeStamp.tv_sec #设置秒数
        packagedFile['timestamp']['nanos']=mtimeStamp.tv_nsec #设置纳秒数
        
        packagedFile['permission']=(File.stat(directoryPath).mode & 07777 ) #设置权限信息
    rescue Errno::ENOENT
    rescue Errno::EACCES #权限受限
    end #begin #读取时间戳
    
    subFileStartIndex=startIndex #子文件的起始位置，以此目录的起始位置为基准。
    
    packagedFile['file_length']=0 #本目录的内容长度。
    
    puts "Listing for #{directoryPathName}" # Debug
    
    packagedSubFile = false # 是否应当删除
    
    directoryPathName.each_child do |subFile| #一个个文件地处理。
        begin
            puts "remove sub file name: #{subFile}" # debug
            
                        realPath=subFile.expand_path #获取绝对路径。
                        
                        subFile.delete # 删除

                        #File.remove realPath # 删除
            #subFile.remove # 删除
            
            
        rescue Errno::EMFILE # File not exist
            puts "Rescued by Errno::EMFILE statement. #{subFile}" #报告错误
        end
    end #directoryPathName.each_child do |subFile| #一个个文件地处理。

end #def downloadOne #下载一个视频。
    

def checkOnce(directoryPath, startIndex=0, layer=0) #打包一个目录树。
    packagedFile={} #创建文件消息对象。
    
    packagedFile['sub_files'] = [] #加入到子文件列表中。
    
    directoryPathName=Pathname.new(directoryPath) #构造路径名字对象。
    
    baseName=directoryPathName.basename.to_s #基本文件名。
    
    packagedFile['name']=baseName #设置文件名。
    
    isFile=directoryPathName.file? #是否是文件。
    isSymLink=directoryPathName.symlink? #是否是符号链接
    
    packagedFile['is_file']=isFile #设置属性，是否是文件。
    packagedFile['file_start_index']=startIndex #记录文件内容的开始位置。
    
    packagedFile['is_symlink']=isSymLink #设置属性，是否是符号链接
    
    puts directoryPath #Dbug.
    
    #记录时间戳：
    begin #读取时间戳
        mtimeStamp=File.mtime(directoryPath) #获取时间戳
        
        packagedFile['timestamp']={} #时间戳
        packagedFile['timestamp']['seconds']=mtimeStamp.tv_sec #设置秒数
        packagedFile['timestamp']['nanos']=mtimeStamp.tv_nsec #设置纳秒数
        
        packagedFile['permission']=(File.stat(directoryPath).mode & 07777 ) #设置权限信息
    rescue Errno::ENOENT
    rescue Errno::EACCES #权限受限
    end #begin #读取时间戳
    
    subFileStartIndex=startIndex #子文件的起始位置，以此目录的起始位置为基准。
    
    packagedFile['file_length']=0 #本目录的内容长度。
    
    puts "Listing for #{directoryPathName}" # Debug
    
    packagedSubFile = false # 是否应当删除
    
    directoryPathName.each_child do |subFile| #一个个文件地处理。
        begin
            puts "sub file name: #{subFile}" # debug
            
            realPath=subFile.expand_path #获取绝对路径。
            
            packagedSubFile, determined=checkOnceMetadata(realPath,subFileStartIndex, layer+1) #打包这个子文件。
            
            if determined # 得到确定结论
                
                
                break # 不再循环
            end # if packagedSubFile # 应当删除
            
        rescue Errno::EMFILE # File not exist
            puts "Rescued by Errno::EMFILE statement. #{subFile}" #报告错误
        end
    end #directoryPathName.each_child do |subFile| #一个个文件地处理。

        if packagedSubFile # 应当删除
            remove_directory_content directoryPath # 删除目录下内容
        end # if packagedSubFile # 应当删除
end #def downloadOne #下载一个视频。


$rootPath=ARGV[0] #记录要打包的目录树的根目录。



directoryPath=$rootPath

puts "direcotry path: #{directoryPath}" # Debug

directoryPathName=Pathname.new(directoryPath) #构造路径名字对象。

directoryPathName.each_child do |subFile| #一个个文件地处理。
    begin
        puts "sub file: #{subFile}" # Debug
        
        realPath=subFile.expand_path #获取绝对路径。
        
        packagedSubFile,subFileContent=checkOnce(realPath) #打包这个子文件。
        
    rescue Errno::EMFILE # File not exist
        puts "Rescued by Errno::EMFILE statement. #{subFile}" #报告错误
    end
end #directoryPathName.each_child do |subFile| #一个个文件地处理。
