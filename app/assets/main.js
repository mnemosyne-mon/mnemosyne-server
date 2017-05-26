import 'timeago'
import 'tether'
import 'bootstrap/js/src/popover'

import { heatmap } from 'heatmap'

jQuery(document).ready(function() {
  $('[data-time-ago]').timeago()

  $('#heatmap').each((_, el) => {
    heatmap(el)
  })

  $('[data-popover-data]').each((_, el) => {
    let $el = $(el)
    let meta = $el.data('popover-data')

    if(!jQuery.isEmptyObject(meta)) {

      let $list = $('<dl></dl>')
      $list.addClass('span-details')

      for(let [key, value] of Object.entries(meta)) {
        $list.append($(`<dt>${key}</dt><dd>${value}</dd>`))
      }

      $el.popover({
        trigger: 'click hover',
        content: $list.get(0),
        html: true
      })
    }
  })
})
