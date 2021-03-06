jQuery ->
  $('#payroll-user-table').dataTable()

  $('#payroll-category-table').dataTable()

  $('#hours_dialog').dialog
    dialogClass: "no-close",
    autoOpen: false,
    buttons: [{
      text: "Ok"
      click: ->
        $(this).dialog("close")
    }]

  $('#hours_dialog_q').click ->
    $('#hours_dialog').dialog("open")
    event.preventDefault
    false

  $('#categories_dialog').dialog
    dialogClass: "no-close",
    autoOpen: false,
    buttons: [{
      text: "Ok"
      click: ->
        $(this).dialog("close")
    }]

  $('#categories_dialog_q').click ->
    $('#categories_dialog').dialog("open")
    event.preventDefault
    false

  $('.cat_users_dialog_link').click ->
    $('#category_users_dialog').html("")
    $('#category_users_dialog').html(
      "<%= escape_javascript(render 'category_users_dialog') %>"
    )

