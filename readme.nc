
### json interface

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