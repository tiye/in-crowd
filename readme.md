
### json interface  

#### for chat  

set-name:  

    <--
      name: 'name'

has-error:  

    -->
      info: 'details'

topic-list:  

    -->
      []
        name: 'name'
        date: '01/23'
        time: '12:34'
        text: 'texts'
        mark: '1233423345'

post-list:  

    <--
      mark: '1233423345'
    -->
      []
        name: 'name'
        date: '01/23'
        time: '12:34'
        text: 'texts'
        mark: '1233423345'
        topic: '1233423345'

add-topic:  

    <--
      text: 'texts'
    -->
      name: 'name'
      date: '01/23'
      time: '12:34'
      text: 'texts'
      mark: '1233423345'

add_post:  

    <--
      text: 'texts'
    -->
      name: 'name'
      date: '01/23'
      time: '12:34'
      text: 'texts'
      mark: '1233423345'

sync-post:  

    <--
      head: 3
      text: 'texts'
    -->
      head: 3
      text: 'texts'
      mark: '1233423345'

leave-topic:  

    <--

new-post:  

    -->
      name: 'name'
      date: '01:23'
      time: '12:34'
      text: 'texts'
      mark: '1233423345'

#### for log  

login-auth:  

    <--
      name: 'name'
      auth: 'texts'

has-error:  

    -->
      info: 'texts'

topic-list:  

    <--
      mark: '1233423345'
    -->
      []
        name: 'name'
        date: '01:23'
        time: '12:34'
        text: 'texts'
        mark: '1233423345'

post-list:  

    <--
      mark: '1233423345'
    -->
      []
        name: 'name'
        date: '01:23'
        time: '12:34'
        text: 'texts'
        mark: '1233423345'

remove-topic:  

    <--
      mark: '1233423345'
    -->
      mark: '1233423345'

remove-post:  

    <--
      mark: '1233423345'
      topic: '1233423345'
    -->
      mark: '1233423345'
      topic: '1233423345'

### dependencies  

`mongodb` and `socket.io` are the fundamentals.  
They are installed globally on my laptop.  

`Bootstrap` and `jQuery` are included in the project.  
For they are much larger than mime, I choose not to put them in the repo.  
So, please notice the file tree of `clients/` folder.  


    $ tree clients/
    clients/
    ├── bootstrap
    │   ├── css
    │   │   ├── bootstrap.css
    │   │   └── bootstrap.min.css
    │   ├── img
    │   │   ├── glyphicons-halflings.png
    │   │   └── glyphicons-halflings-white.png
    │   └── js
    │       ├── bootstrap.js
    │       └── bootstrap.min.js
    ├── demo.coffee
    ├── demo.css
    ├── demo.html
    ├── demo.jade
    ├── demo.js
    └── jquery.js

    4 directories, 12 files

### Shortcuts  

Several shortcuts are available:  

* `tab` to focus on the say box  
* `up arrow` move up for one item  
* `down arrow` move down for one item  
* `esc` toggle the page back and forth  

### More  

I haven't written code for the link `/log`, but soon I will.  
And the demo client should be put on a file server,  
for example: <https://gist.github.com/2959922>  

I just want to choose MIT Licence for my code.  
Considering `bootstrap` was used, I'm not sure if that conflicts or not...?  