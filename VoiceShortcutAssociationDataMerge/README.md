此脚本用于从rabbitmq的消息队列中接收由灵桌面安卓软件回传的统计信息，并合并到本地统计信息数据中。

使用bunny来连接消息队列，使用protobuf来封包、解包。