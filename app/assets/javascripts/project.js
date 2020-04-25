$(document).on('turbolinks:load', function() {
  $('.js-datetimepicker').datetimepicker({
    lang: 'ru',
    format: 'd.m.Y H:i',
    step: 5
  });

  $('.close').click(function() {
    $(this).parent().remove();
  });
});
