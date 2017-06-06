import {
  Component,
  createElement as $
} from './core'

import URI from 'urijs'
import 'urijs/src/URITemplate'

import PropTypes from 'prop-types'

import './TraceView.sass'

import { TraceInfo } from './TraceInfo'
import { TraceMeta } from './TraceMeta'
import { TraceGraph } from './TraceGraph'

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
  @childContextTypes =
    routes: PropTypes.object

  getChildContext: ->
    {
      routes: makeRoutes(this.props.routes)
    }

  render: ->
    console.log(this.props.routes)
    { trace, spans } = this.props

    $ 'section', className: 'traceview',
      $ Header,
        uuid: this.props['trace']['uuid']
      $ 'div', className: 'container-fluid',
        $ TraceInfo, trace: trace
        $ TraceMeta, trace: trace
      $ 'div', className: 'container-fluid',
        $ TraceGraph, nodes: [trace, spans...]


class Header extends Component
  @contextTypes =
    routes: PropTypes.object

  render: ->
    $ 'header',
      $ 'h2', 'Trace Details'
      $ 'a',
        href: this.context.routes.t_url(id: this.props.uuid)
        $ 'span', this.props.uuid
        $ 'small', '(direct link)'
