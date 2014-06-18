
module.exports = React.createClass
  displayName: 'messages-view'

  componentDidMount: ->

  render: ->
    $.div
      id: 'messages-view'
      className: 'app-body flex-fill'
      'messages'