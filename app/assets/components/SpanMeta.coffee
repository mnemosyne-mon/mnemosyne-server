import {
  Component,
  createElement as $
} from './core'

import IconClose from 'preact-icons/fa/close'

to_link = (obj, cb) =>
  if obj?.url?
    $ 'a', href: obj.url, cb()
  else
    cb()

export class SpanMeta extends Component
  render: ->
    node = this.props.node

    $ 'section',
      className: 'traceview-sm'
      $ 'a',
        href: '#'
        className: 'sm-close'
        onClick: this.props.onCloseRequest
        $ IconClose

      $ 'section',
        $ 'h3', 'Details'
        $ 'table',
          $ 'tbody',
            $ 'tr',
              $ 'th', 'UUID'
              $ 'td', node.uuid
            $ 'tr',
              $ 'th', 'Name'
              $ 'td', node.name
            $ 'tr',
              $ 'th', 'Duration'
              $ 'td', node.duration.toFixed(2) + ' ms'
            $ 'tr',
              $ 'th', 'Application'
              $ 'td', to_link(node.application, => node.application.name)
            $ 'tr',
              $ 'th', 'Transaction'
              $ 'td', to_link(node.activity, => node.activity.uuid)
            if node.trace?
              $ 'tr',
                $ 'th', 'Trace'
                $ 'td', to_link(node.trace, => node.trace.uuid)

      $ 'section',
        $ 'h4', 'Meta'

        $ 'dl', null,
          for key, value of this.props.node['meta']
            unless typeof value == 'string' or typeof value == 'number'
              value = JSON.stringify(value, null, '  ')

            if value == ''
              value = $ 'span', className: 'empty', '<none>'

            [
              $ 'dt', key
              $ 'dd', value
            ]
