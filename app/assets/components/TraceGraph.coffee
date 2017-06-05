import {
  Component,
  createElement as $
} from './core'

import PropTypes from 'prop-types'

import './TraceGraph.sass'

export class TraceGraph extends Component
  @contextTypes =
    routes: PropTypes.object

  render: ->
    $ 'section', className: 'tracegraph',
      this.props.nodes.map this.renderNode.bind(this)

  renderNode: (node) ->
    $ 'div', key: node.uuid,
      $ 'div', className: 'tg-info', this.renderName(node)
      $ 'div', this.renderBar(node)

  renderName: (node) ->
    if node.traces?.length > 0
      $ 'a',
        href: this.context.routes.traces_url() + '/' + node.traces[0]
        node.title || node.name
    else
      node.title || node.name

  renderBar: (node) ->
    style = {}

    if node.metric?
      style.width = "#{node.metric.width}%"
      style.marginLeft = "#{node.metric.offset}%"

    if node.duration?
      duration = node.duration.toFixed(2) + ' ms'

    $ 'span',
      className: 'tg-bar'
      title: duration
      style: style
