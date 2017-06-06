import {
  Component,
  createElement as $
} from './core'

import URIJS from 'urijs'
import PropTypes from 'prop-types'

import { Field } from './TraceInfo'

export class TraceMeta extends Component
  render: ->
    switch this.props.trace.type
      when 'web'
        $ WebMeta, meta: this.props.trace.meta
      when 'job'
        $ JobMeta, meta: this.props.trace.meta
      else
        null


class WebMeta extends Component
  @contextTypes =
    routes: PropTypes.object

  render: ->
    { routes } = this.context
    { meta } = this.props

    $ 'section', className: 'traceinfo',
      $ Field,
        title: 'Method'
        value: meta['method']
        href: routes.traces_url(wm: meta['method'])
      $ Field,
        title: 'Domain'
        value: meta['host']
        href: routes.traces_url(wh: meta['host']) if meta['host']?
      $ Field,
        title: 'User Agent'
        value: meta['user_agent']
      $ Field,
        title: 'Controller'
        value: meta['controller']
        href: routes.traces_url(wc: meta['controller']) if meta['controller']?
      $ Field,
        title: 'Status'
        value: meta['status']
        href: routes.traces_url(ws: meta['status']) if meta['status']?
      $ Field,
        title: 'Path'
        value: meta['path']
        href: routes.traces_url(wp: meta['path']) if meta['path']?
      $ Field,
        title: 'Query'
        value: meta['query']
      $ Field,
        title: 'Action'
        value: meta['action']
        href: routes.traces_url(wa: meta['action']) if meta['action']?


class JobMeta extends Component
  @contextTypes =
    routes: PropTypes.object

  render: ->
    $ 'section', className: 'traceinfo',
      $ Field,
        title: 'Class',
        value: this.props.meta['class']
      $ Field,
        title: 'Method',
        value: this.props.meta['method']
