import {
  Component,
  createElement as $
} from './core'

import PropTypes from 'prop-types'

import './TraceGraph.sass'

export class TraceGraph extends Component
  @contextTypes =
    routes: PropTypes.object

  constructor: (props) ->
    super(props)

  componentDidMount: ->
    if window.location.hash.startsWith('#sm-')
      uuid = window.location.hash.slice(4)

      for node in this.props.nodes
        if node['uuid'] == uuid
          this.props.onSelect?(uuid)

  render: ->
    $ 'section', className: 'tracegraph',
      this.props.nodes.map this.renderNode.bind(this)

  renderNode: (node) ->
    selected = this.props.selection == node['uuid']

    $ 'div',
      key: node.uuid
      className: 'selected' if selected
      $ 'div', className: 'tg-info', this.renderName(node)
      $ 'div', this.renderBar(node)

  renderName: (node) ->
    $ 'a',
      href: "#sm-#{node['uuid']}"
      onClick: => this.props.onSelect(node['uuid'])
      node.title || node.name

    # if node.traces?.length > 0
    #   $ 'a',
    #     href: this.context.routes.traces_url(id: node.traces[0])
    #     node.title || node.name
    # else
    #   node.title || node.name

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
