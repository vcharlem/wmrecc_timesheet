# make a date Ruby can handle
weekday_name = (n) ->
  weekday = new Array(7)
  weekday[0] =  "Sunday"
  weekday[1] = "Monday"
  weekday[2] = "Tuesday"
  weekday[3] = "Wednesday"
  weekday[4] = "Thursday"
  weekday[5] = "Friday"
  weekday[6] = "Saturday"
  weekday[n]

rubyReadyDate = ->
  n = new Date()
  y = n.getFullYear()
  m = n.getMonth()
  d = n.getDate()
  y + '/' + m + '/' + d

calculateTotal = (input, ttl_field) ->
  sum = 0
  $(input).each ->
    if !isNaN(this.value) && this.value.length != 0
      sum += parseFloat this.value
    $(ttl_field).html(sum)

holiday_date_filter = (holiday) ->
  string_date = holiday["date"]
  date = new Date(string_date)
  formatted_date = weekday_name(date.getDay())+", "+(date.getMonth()+1)+"/"+(date.getDate()+1)
  name = "<li>"+holiday["name"]+" is "+formatted_date+"</li>"
  first_string = $('#start_of_range').html()
  first = new Date(first_string)
  last_string = $('#end_of_range').html()
  last = new Date(last_string)
  if first <= date && date <= last
    $('#holiday_reminder').removeClass('hidden')
    $('#holidays_in_period').append(name)

holiday_json = ->
  $('#holidays_in_period').html("")
  ary = $('#holiday_ary').html()
  parsed = jQuery.parseJSON(ary)
  holiday_date_filter holiday for holiday, i in parsed


holiday_processor = ->
  $('#holiday_reminder').addClass('hidden')
  mm_dd = $('input.week_num_to_date').val()
  mm = mm_dd.split("/")[0]
  dd = mm_dd.split("/")[1]
  yyyy = $('input#timesheet_year').val()

  visible_date = new Date(mm+"/"+dd+"/"+yyyy)
  day_start_of_wk = (visible_date.getDate() - visible_date.getDay())+1
  start_of_wk = new Date(mm+"/"+day_start_of_wk+"/"+yyyy)
  $('span#start_of_range').html(start_of_wk)

  day_end_of_wk = day_start_of_wk + 6
  end_of_wk = new Date(mm+"/"+day_end_of_wk+"/"+yyyy)
  $('span#end_of_range').html(end_of_wk)
  $.ajax(url: '/holidays/'+yyyy, type: 'get', success: (data)->
    $('span#holiday_ary').html(data)
    holiday_json()
  )

jQuery ->
  # _timesheet_form.html.erb:
  #holiday_processor()


  $(document).on 'changeDate', '.week_num_to_date', ( ->
    holiday_processor()
  )

  $('#direct_report_chooser').click ->
    direct_report = $('#direct_report_select option:selected').val()
    if direct_report == ""
      # Shows the 'Please select a name.' hidden div
      $('#direct_report_error').toggleClass('hidden')
    else
      pathString = "/users/"+direct_report+"/timesheets/new"
      originString = location.origin
      urlString = originString + pathString
      window.location = urlString
    event.preventDefault()
    false

  $('#direct_report_select').change ->
    $('#direct_report_error').addClass('hidden')

  $('#week_num_to_date_field').datepicker
    todayBtn: "linked"
    format: 'mm/dd'
    calendarWeeks: true
    weekStart: 1
    autoclose: true

  $('#week_num_to_date_field').change ->
    new_mm_dd = $(this).val()
    new_yy = $('#timesheet_year').val()
    new_date = new_mm_dd + "/" + new_yy
    $('#timesheet_week_num').val(new Date(new_date).getWeek())

  $('.timesheet_year_field').datepicker
    format: "yyyy"
    minViewMode: 2
    autoclose: true

  $('.timeoff-hide').hide()
  $('.timeoff-show').show()
  $('.expand-5-to-7').removeClass('col-xs-5').addClass('col-xs-7')
  $('.expand-2-to-5').removeClass('col-xs-2').addClass('col-xs-5')

  $('#show_timeoff_switch').click ->
    if $(this).html() == "(add timeoff)"
      htmlString = "(hide timeoff)"
      $('.expand-5-to-7').removeClass('col-xs-7').addClass('col-xs-5')
      $('.expand-2-to-5').removeClass('col-xs-5').addClass('col-xs-2')
      $('.timeoff-hide').show()
      $('.timeoff-show').hide()
    else
      htmlString = "(add timeoff)"
      $('.expand-5-to-7').removeClass('col-xs-5').addClass('col-xs-7')
      $('.expand-2-to-5').removeClass('col-xs-2').addClass('col-xs-5')
      $('.timeoff-hide').hide()
      $('.timeoff-show').show()
    $(this).text( htmlString )
    event.preventDefault()

  # _timesheet_hours_form.html.erb
  $('#review_select_tag').change ->
    if $(this).val() == "true"
      $('.reviewed-field').val(rubyReadyDate())
    else
      $('.reviewed-field').val('')
      $('#approve_select_tag').val('false')
      $('.approved-field').val('')

  $('#approve_select_tag').change ->
    if $(this).val() == "true"
      $('.approved-field').val(rubyReadyDate())
      $('.reviewed-field').val(rubyReadyDate())
      $('#review_select_tag').val('true')
    else
      $('.approved-field').val('')

  $('#to_review_select_tag').change ->
    if $(this).val() == "true"
      $('.timeoff-reviewed-field').val(rubyReadyDate())
    else
      $('.timeoff-reviewed-field').val('')
      $('#to_approve_select_tag').val('false')
      $('.timeoff-approved-field').val('')

  $('#to_approve_select_tag').change ->
    if $(this).val() == "true"
      $('.timeoff-approved-field').val(rubyReadyDate())
      $('.timeoff-reviewed-field').val(rubyReadyDate())
      $('#to_review_select_tag').val('true')
    else
      $('.timeoff-approved-field').val('')

  calculateTotal('.hours-field', '#ttl-hours')
  calculateTotal('.timeoff-hours-field', '#ttl-timeoff-hours')
  
  $('.hours-field').bind 'click keyup', (event) ->
    calculateTotal('.hours-field', '#ttl-hours')

  $('.timeoff-hours-field').bind 'click keyup', (event) ->
    calculateTotal('.timeoff-hours-field', '#ttl-timeoff-hours')

  $('#timesheet-admin-table').dataTable
    columnDefs: [
      targets: -1, sortable: false, searchable: false
    ]

  $('#timesheet-over-table').dataTable
    columnDefs: [
      targets: -1, sortable: false, searchable: false
    ]

  $('#timesheet-single-table').dataTable
    columnDefs: [
      targets: -1, sortable: false, searchable: false
    ]