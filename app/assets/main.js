import 'timeago'

import {
  render
} from 'react-dom'

import {
  createElement
} from 'react'

import {
  heatmap
} from 'heatmap'

import * as components from 'components/index'

function initalize() {
  $('[data-time-ago]').timeago()

  document.querySelectorAll('script[data-component]').forEach((el) => {
    let component = components[el.dataset.component]
    let props = {}

    if(el.type === 'application/json')
    {
      props = JSON.parse(el.innerHTML)
    }

    let node = undefined

    if(!el.dataset.target)
    {
      node = document.createElement(el.dataset.tagname || 'div')
      el.parentNode.replaceChild(node, el)
    }
    else if(el.dataset.target === 'parent')
    {
      node = el.parentNode
    }
    else
    {
      node = document.querySelector(el.dataset.target)
    }

    render(createElement(component, props), node)
  })

  document.querySelectorAll('#heatmap').forEach((el) => heatmap(el))
}

if (document.readyState === "complete" ||
    document.readyState === "loaded" ||
    document.readyState === "interactive") {
  initalize()
} else {
  document.addEventListener('DOMContentLoaded', initalize)
}
