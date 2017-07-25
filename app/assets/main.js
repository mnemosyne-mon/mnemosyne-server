import 'timeago'

import {
  render
} from 'react-dom'

import {
  createElement
} from 'react'

import * as components from 'components/index'

document.addEventListener('DOMContentLoaded', () => {
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
})

jQuery(document).ready(function() {
  $('[data-time-ago]').timeago()
})
