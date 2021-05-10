import {
  Component,
  createElement as $
} from './core'

export class TraceInfo extends Component
  render: ->
    { start, application, origin, hostname } = this.props.trace

    $ 'section', className: 'traceinfo',
      $ Field,
        title: 'Started',
        value: new Date(start)
      $ Field,
        title: 'Application',
        value: application['title']
        href: this.context.routes.traces_url(application: application['uuid'])
      $ Field,
        title: 'Origin',
        value: origin?['uuid']
        href: this.context.routes.traces_url(id: origin['trace']) if origin?['trace']?
      $ Field,
        title: 'Hostname',
        value: hostname,
        href: this.context.routes.traces_url(hostname: hostname)

export class Field extends Component
  render: ->
    { title, value, href } = this.props

    $ 'div',
      $ 'h4', title
      do =>
        if value? && href
          $ 'a', title: value.toString(), href: href, value.toString()
        else if value?
          $ 'p', value
        else
          $ 'a', className: 'empty', '<none>'
