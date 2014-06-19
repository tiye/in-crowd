
TopicsView = require './topics'
MesssagesView = require './messages'

module.exports = React.createClass
  displayName: 'app-view'

  render: ->
    $.div
      id: 'app-view'
      className: 'app-root row-strech'
      TopicsView({})
      MesssagesView({})