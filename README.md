
介绍  
--

简单的聊天功能, 话题列表和聊天界面, 不过纯粹只有聊天的骨架  
运行在 NAE 上(关了 websocket): <http://zhongli.cnodejs.net/>  
用了`socket.io`同步输入和界面, 还有`mongodb`存储  

安装  
--

需要[`mongodb`][ln1]环境, 配置用户需要一些数据库管理的知识, 介绍比较难  
还有依赖`socket.io`, 因此需要安装两个模块  
`package.json`没有测试, 是为在 NAE 正常运行添加的, 不能用在安装  
如果有`CoffeeScript`环境就可以运行`$ coffee app,coffee`  
否则需要安装`$ sudo npm install coffee-script -g`, 注意`npm`是必需的  

功能  
--

* 点击按钮添加 topic  
* 回车键打开关闭聊天的输入框  
* 实时同步到字符  
* 离开页面时, 标签上给出相应通知  
* 正在输入的文字的颜色  

不足  
--

* 界面太简单, 打算 CSS 添加样式  
* 操作过程的比较晦涩, 绑定点击和快捷键不明显  
* 帖子标题没有根据最后回复时间改变排序  
* 用户 IP 暴露到 id 上面, 存在隐患  
* 通信 id 是 IP 和时间的拼接, 时间不统一  

计划  
--

虽然不难, 我还是分开几个时间段来做好了  

使用  
--

任意, 别害得别人折腾..  

[ln1]: http://www.cnblogs.com/silentcross/archive/2011/07/26/2116509.html
