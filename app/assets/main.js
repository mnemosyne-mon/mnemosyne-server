import 'timeago'

import { heatmap } from 'heatmap'

jQuery(document).ready(function() {
  $('[data-time-ago]').timeago()

  $('#heatmap').each(function() {
    heatmap(this)
  })
})
