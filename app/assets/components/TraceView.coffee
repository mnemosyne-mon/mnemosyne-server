import {
  Component,
  createElement as $
} from './core'

import IconStar from 'preact-icons/fa/star'
import IconStarOff from 'preact-icons/fa/star-o'

import URI from 'urijs'
import 'urijs/src/URITemplate'

import './TraceView.sass'

import { TraceInfo } from './TraceInfo'
import { TraceMeta } from './TraceMeta'
import { TraceFailures } from './TraceFailures'
import { TraceGraph } from './TraceGraph'
import { SpanMeta } from './SpanMeta'

makeRoutes = (routes) ->
  helpers = Object.create(null)

  for key in Object.keys(routes)
    helpers[key] = do(uri = routes[key]) ->
      (data = {}) =>
        URI.expand uri, (x) ->
            prop = data[x]
            delete data[x]
            prop
          .query(data)

  helpers


export class TraceView extends Component
  constructor: (props) ->
    super(props)

    this.state = {}

    this.__onHashChange = this.onHashChange.bind(this)

  getChildContext: ->
    {
      routes: makeRoutes(this.props.routes)
    }

  componentDidMount: ->
    this.onHashChange()
    window.addEventListener 'hashchange', this.__onHashChange

  componentWillUnmount: ->
    window.removeEventListener 'hashchange', this.__onHashChange

  onHashChange: (e) ->
    if window.location.hash.startsWith('#sm-')
      this.select window.location.hash.slice(4)
    else
      this.setState selection: null

  select: (uuid) ->
    for span in this.props.spans
      if span['uuid'] == uuid
        this.setState selection: span
        break

  render: ->
    { trace, spans, failures } = this.props

    $ 'section', className: 'traceview',
      $ Header,
        trace: this.props.trace
      $ 'div', className: 'container-fluid',
        $ TraceInfo, trace: trace
        $ TraceMeta, trace: trace
      if failures.length > 0
        $ 'div', className: 'container-fluid',
          $ TraceFailures, failures: failures
      $ 'div', className: 'container-fluid traceview-main',
        $ TraceGraph,
          trace: trace,
          spans: [spans...],
          selection: this.state.selection?['uuid']
          onSelect: this.select.bind(this)
        if this.state.selection?
          $ SpanMeta,
            node: this.state.selection
            onCloseRequest: => this.setState selection: null


class Header extends Component
  toggleSave: ->
    { trace } = this.props

    token = document.querySelector('meta[name="csrf-token"]').content
    url = this.context.routes.traces_url(id: trace.uuid)

    response = await fetch url,
      method: 'PATCH'
      credentials: 'same-origin'
      headers:
        'Accept': 'application/json'
        'Content-Type': 'application/json'
        'X-CSRF-Token': token
      body: JSON.stringify store: !trace.store

    if response.ok
      location.reload()

  render: ->
    { trace } = this.props

    $ 'header',
      $ 'h2',
        if trace.store
          $ 'a',
            href: '#'
            onClick: => this.toggleSave()
            title: 'Trace saved'
            $ IconStar
        else
          $ 'a',
            href: '#'
            onClick: => this.toggleSave()
            title: 'Save trace'
            $ IconStarOff
        'Trace Details'
      $ 'a',
        href: this.context.routes.t_url(id: trace.uuid)
        $ 'span', trace.uuid
        $ 'small', '(direct link)'
