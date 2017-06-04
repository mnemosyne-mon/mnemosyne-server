import {
  Component,
  createElement as $
} from './core'

import URIJS from 'urijs'
import PropTypes from 'prop-types'

import './TraceView.sass'

makeRoutes = (routes) ->
  helpers = Object.create(null)

  for key in Object.keys(routes)
    helpers[key] = do(uri = URIJS(routes[key])) ->
      (query) => uri.query(query).toString()

  helpers

export class TraceView extends Component
  @childContextTypes =
    routes: PropTypes.object

  getChildContext: ->
    {
      routes: makeRoutes(this.props.routes)
    }

  render: ->
    { trace, spans } = this.props

    $ 'section', className: 'traceview',
      $ Header,
        id: this.props['trace']['uuid']
      $ 'div', className: 'container-fluid',
        $ TraceInfo, trace: trace
        $ TraceDetails, trace: trace

class Header extends Component
  render: ->
    $ 'header',
      $ 'h2', 'Trace Details'
      $ 'span', this.props.id

class TraceInfo extends Component
  @contextTypes =
    routes: PropTypes.object

  render: ->
    { start, application, origin_uuid, origin_url, hostname } = this.props.trace

    console.log(this.props)

    $ 'section', className: 'traceinfo',
      $ TraceInfoField,
        title: 'Started',
        value: new Date(start)
      $ TraceInfoField,
        title: 'Application',
        value: application['name']
        href: this.context.routes.traces_url(application: application['uuid'])
      $ TraceInfoField,
        title: 'Origin',
        value: origin_uuid
        href: origin_url
      $ TraceInfoField,
        title: 'Hostname',
        value: hostname,
        href: this.context.routes.traces_url(hostname: hostname)

class TraceDetails extends Component
  @contextTypes =
    routes: PropTypes.object

  render: ->
    $ 'section', className: 'traceinfo',
      $ TraceInfoField,
        title: 'Method',
        value: this.props.trace['meta']['method']
        href: this.context.routes.traces_url(method: this.props.trace['meta']['method'])
      $ TraceInfoField,
        title: 'Domain',
        value: this.props.trace['meta']['host']
      $ TraceInfoField,
        title: 'User Agent',
        value: this.props.trace['meta']['user_agent']
      $ TraceInfoField,
        title: 'Controller',
        value: null
      $ TraceInfoField,
        title: 'Status',
        value: this.props.trace['meta']['status']
      $ TraceInfoField,
        title: 'Path',
        value: this.props.trace['meta']['path']
      $ TraceInfoField,
        title: 'Query',
        value: this.props.trace['meta']['query']
      $ TraceInfoField,
        title: 'Action',
        value: null

class TraceInfoField extends Component
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
