import {
  Component,
  createElement as $
} from './core'

export class TraceFailures extends Component
  render: ->
    $ 'div', className: 'tracefailures',
      $ 'p', 'Failures attached to this trace:'
      $ 'ul',
        this.props.failures.map this.renderFailure.bind(this)

  renderFailure: (failure) ->
    $ 'li',
      $ 'a', href: failure['path'],
        failure['type']
        $ 'span', failure['text']
