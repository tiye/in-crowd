
Noisy-Chat 想做实时聊天工具, Node.js 搭的, 没有数据库支持.  
原先很想多有功能的, 可写这代码畏怯了, 规划结构的能力成问题啊.  
现在我先录个半成品的视频放上土豆再说, 是否修补明天再说.  

### message protocals  

'visit-page'  

    send =
      title: 'topic'

    get =
      title: 'topic'
      list: [topic]

'set-name'  

    send =
      name: 'name'

    get =
      status: 'ok'
      info: 'this name is ok'

'error'  

    info: 'reason for error'

'add-topic'  

    send =
      text: 'content'

    get =
      type: 'topic'
      name: 'name'
      time: '23:45'
      mark: mark()
      text: 'content'
      topic: mark()

'add-post'  

    send =
      text: 'content'

    get =
      topic: mark()
      type: 'post'
      name: 'name'
      time: '23:45'
      mark: mark()
      text: 'content'