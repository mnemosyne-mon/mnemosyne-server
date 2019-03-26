import {
  h,
  render
} from 'preact'

import { TraceView, TimeHeader } from 'components/index'

const components = {
  TraceView: TraceView,
  TimeHeader: TimeHeader
}

function initalize() {
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

    render(h(component, props), node.parentElement, node)
  })
}

if (document.readyState === "complete" ||
    document.readyState === "loaded" ||
    document.readyState === "interactive") {
  initalize()
} else {
  document.addEventListener('DOMContentLoaded', initalize)
}
