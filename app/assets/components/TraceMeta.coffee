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
    $ 'section', className: 'traceinfo',
      $ Field,
        title: 'Method',
        value: this.props.meta['method']
        href: this.context.routes.traces_url(method: this.props.meta['method'])
      $ Field,
        title: 'Domain',
        value: this.props.meta['host']
      $ Field,
        title: 'User Agent',
        value: this.props.meta['user_agent']
      $ Field,
        title: 'Controller',
        value: this.props.meta['controller']
      $ Field,
        title: 'Status',
        value: this.props.meta['status']
      $ Field,
        title: 'Path',
        value: this.props.meta['path']
      $ Field,
        title: 'Query',
        value: this.props.meta['query']
      $ Field,
        title: 'Action',
        value: this.props.meta['action']


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
