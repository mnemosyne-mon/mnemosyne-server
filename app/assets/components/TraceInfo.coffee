import {
  Component,
  createElement as $
} from './core'

import PropTypes from 'prop-types'


export class TraceInfo extends Component
  @contextTypes =
    routes: PropTypes.object

  render: ->
    { start, application, origin, hostname } = this.props.trace

    $ 'section', className: 'traceinfo',
      $ Field,
        title: 'Started',
        value: new Date(start)
      $ Field,
        title: 'Application',
        value: application['name']
        href: this.context.routes.traces_url(application: application['uuid'])
      $ Field,
        title: 'Origin',
        value: origin?['uuid']
        href: this.context.routes.traces_url(id: origin['trace']) if origin?
      $ Field,
        title: 'Hostname',
        value: hostname,
        href: this.context.routes.traces_url(hostname: hostname)

export class Field extends Component
  render: ->
    { title, value, href } = this.props

    if value?
      value = value.toString()

    $ 'div',
      $ 'h4', title
      do =>
        if value
          $ 'a', title: value, href: href, value
        else
          $ 'a', className: 'empty', '<none>'
