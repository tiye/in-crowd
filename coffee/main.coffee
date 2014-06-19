
require('./util/extend')

AppView = require './views/app'

React.renderComponent AppView({}), document.body
