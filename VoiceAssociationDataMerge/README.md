VoiceAssociationDataMerge.rb
==

从AMQP消息队列服务器中接收由灵桌面安卓应用回传的统计数据，再合并到本地已有的统计数据中。统计数据本身使用protobuf来封装。

voiceAssociationDataList.rb
==

列出本地以protobuf格式储存的统计数据中的详细条目，供肉眼查看数据，并且输出一个自然语言处理的训练数据集。该训练数据集将被一个基于nlp.js的自然语言处理模块训练成模型，放置于云端，用于辅助灵桌面安卓应用提升语音识别指令的准确度。

voiceAssociationDataMigrateToMultiMap.rb
==

灵桌面的统计数据格式曾经过升级，具体就是，其中的某种映射关系，由一对一的映射升级成一对多的映射。此脚本用于将本地的统计数据格式进行对应的升级。

voiceAssociationDataMigrateToMultiMapPurge.rb
==

此脚本用于将格式升级后的统计数据文件中的一些无用内容剔除掉。
