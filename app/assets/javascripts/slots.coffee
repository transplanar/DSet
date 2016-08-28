jQuery ->
  $('#card_search').submit( ->
    $.get(this.action, $(this).serialize(), null, 'script')
    false
  )

  $('#card_search input').keyup( ->
    $.get($("#card_search").attr("action"), $("#card_search").serialize(), null, 'script')
    false
  )

  $(document).ready( ->
    $.get($("#card_search").attr("action"), $("#card_search").serialize(), null, 'script')
    false
  )
