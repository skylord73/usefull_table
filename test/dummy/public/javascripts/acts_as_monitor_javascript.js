document.observe('dom:loaded', function()
{
  var application_root ='';
  create_status_window();
  //alert(application_root);

  function create_status_window() {
    /*new Insertion.Bottom(
      document.body, 
      "<div id='acts_as_monitor_status_window'><%= Rails.root %></div>"
    );*/
    var status_window = $('acts_as_monitor_status_window');
    Position.absolutize(status_window);
    status_window.observe('click', function(ev) {status_window.fade(); });
    status_window.hide();
    //The helper provide the Rails.root inside the created div...
    application_root = status_window.innerHTML;
  }

  var handle_monitor = function(ev)
  {
    var id = ev.target.getAttribute('data-id');
    var image = ev.target.src;
    new Ajax.Request(application_root + '/acts_as_monitor/monitors/'+ id +'.js', 
    {
      method: 'get',
      evalJSON: 'force',
      parameters: {
        class_name: ev.target.getAttribute('data-class')
      },
      onLoading: function(response){
        ev.target.src = application_root + '/images/acts_as_monitor_loading.gif';
      },
      onSuccess: function(response){
        var rsp = response.responseJSON;
        ev.target.src = image;
        create_popup(rsp.text,ev.target);
      },
      onFailure: function(response) 
      {
        alert('Failure ' + response.status);
      }
    });
  }

  //Create popup with information
  function create_popup(text,target)
  {
    //alert(text);
    var status_window = $('acts_as_monitor_status_window');
    status_window.update(text);
    Position.clone(target,
      status_window, {
        offsetLeft: 20
      });
    new Effect.Appear(status_window);
    //alert("Fatto");
  }

  //$$('.acts_as_monitor_icon_red .acts_as_monitor_icon_yellow .acts_as_monitor_icon_green') 
  var pulsate_forever = function(elem) {
    new Effect.Pulsate(elem, {
      //afterFinish: function(o) { new Effect.Pulsate(o.element, o.options); }
      duration: 600,
      pulses: 1500
    });
  }
  $$('.acts_as_monitor_icon_red').each(function(elmt)
    {
    elmt.observe('click', handle_monitor);
    pulsate_forever(elmt);
    }); 
  
  $$('.acts_as_monitor_icon_yellow').each(function(elmt)
    {
    elmt.observe('click', handle_monitor);
    }); 
});
