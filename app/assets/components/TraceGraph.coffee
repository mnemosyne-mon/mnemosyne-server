import {
  Component,
  createElement as $
} from './core'
import './TraceGraph.sass'

export class TraceGraph extends Component
  render: ->
    $ 'section', className: 'tracegraph',
      this.props.nodes.map this.renderNode.bind(this)

  select: (uuid) ->
    window.location.hash = "#sm-#{uuid}"
    this.props.onSelect(uuid)

  renderNode: (node) ->
    selected = this.props.selection == node['uuid']

    $ 'div',
      key: node.uuid
      className: 'selected' if selected
      onClick: => this.select(node['uuid'])
      $ 'div',
        className: 'tg-info',
        this.renderName(node)
      $ 'div', this.renderBar(node)

  renderName: (node) ->
    if node.children
      $ 'a',
        href: this.context.routes.traces_url(origin: node.uuid)
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
      if node.duration > 10
        $ 'span', node.duration.toFixed(2)
