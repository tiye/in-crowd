
### json interface

set-name:
  <--
    name: 'name'

has-error:
  -->
    info: 'details'

topic-list:
  <--
    full: yes | no
  -->
    []
      name: 'name'
      date: '01:23'
      time: '12:34'
      text: 'texts'
      mark: '1233423345'

post-list:
  <--
    full: yes | no
  -->
    []
      name: 'name'
      date: '01:23'
      time: '12:34'
      text: 'texts'
      mark: '1233423345'

add-topic:
  <--
    text: 'texts'

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

rm-post:
  <--
    mark: '1233423345'

rm-topic:
  <--
    mark: '1233423345'