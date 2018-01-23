import {
  Component,
  createElement as $
} from './core'

import URIJS from 'urijs'

import { Field } from './TraceInfo'

export class TraceMeta extends Component
  render: ->
    switch this.props.trace.type
      when 'web'
        $ WebMeta, trace: this.props.trace
      when 'job'
        $ JobMeta, meta: this.props.trace.meta
      else
        null


class WebMeta extends Component
  render: ->
    { routes } = this.context
    { application, meta } = this.props.trace

    $ 'section', className: 'traceinfo',
      $ Field,
        title: 'Method'
        value: meta['method']
        href: routes.traces_url(wm: meta['method'])
      $ Field,
        title: 'Domain'
        value: meta['host']
        href: routes.traces_url(application: application['uuid'], wh: meta['host']) if meta['host']?
      $ Field,
        title: 'User Agent'
        value: meta['user_agent']
      $ Field,
        title: 'Controller'
        value: meta['controller']
        href: routes.traces_url(application: application['uuid'], wc: meta['controller']) if meta['controller']?
      $ Field,
        title: 'Status'
        value: meta['status']
        href: routes.traces_url(ws: meta['status']) if meta['status']?
      $ Field,
        title: 'Path'
        value: meta['path']
        href: routes.traces_url(application: application['uuid'], wp: meta['path']) if meta['path']?
      $ Field,
        title: 'Query'
        value: meta['query']
      $ Field,
        title: 'Action'
        value: meta['action']
        href: routes.traces_url(application: application['uuid'], wc: meta['controller'], wa: meta['action']) if meta['action']?


class JobMeta extends Component
  render: ->
    $ 'section', className: 'traceinfo',
      $ Field,
        title: 'Class',
        value: this.props.meta['class']
      $ Field,
        title: 'Method',
        value: this.props.meta['method']
