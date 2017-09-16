import {
  Component,
  createElement as $
} from './core'

import IconClose from 'preact-icons/fa/close'

export class SpanMeta extends Component
  render: ->
    $ 'section',
      className: 'traceview-sm'
      $ 'a',
        href: '#'
        className: 'sm-close'
        onClick: this.props.onCloseRequest
        $ IconClose

      $ 'section',
        $ 'h3', 'Trace Details'
        $ 'table',
          $ 'tbody',
            $ 'tr',
              $ 'th', 'UUID'
              $ 'td', this.props.node['uuid']
            $ 'tr',
              $ 'th', 'Name'
              $ 'td', this.props.node['name']
            $ 'tr',
              $ 'th', 'Duration'
              $ 'td', this.props.node['duration'].toFixed(2) + ' ms'

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
