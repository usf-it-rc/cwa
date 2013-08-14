// Catch click events
if (document.addEventListener) {
  document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
  }, false);
  document.addEventListener('click', function() {
    clearMenu();
  }, false);
} else {
  document.attachEvent('oncontextmenu', function() {
    window.event.returnValue = false;
  });
  document.attachEvent('onclick', function() {
    clearMenu();
  });
};

// This should be set by the application first!
var redmine_project;

var tail_handle;
var my_tail_func = function(){
  var data = "";
  $.post("/cwa_browser/" + redmine_project + "/" + $('#selected_file').val() + "/tail",
    function(data){ 
      $('#tail_content').val('');
      $('#tail_content').val(data);
    }
  );
  
  $("#tail_content").scrollTop($("#tail_content")[0].scrollHeight);
};

function cwaAction(action, promptString, confirmBool){
  var item = $('#selected_item').val();
  item = item.split("/");
  item = item[item.length-1];

  var path = $("#selected_dir").val();
  var share = $("#selected_share").val();
  var argument;
  var continuation = false;

  if (promptString){
    argument = prompt(promptString);

    url = "/cwa_browser/" + redmine_project + "/";
    url += share + "/";
    if (path)
      url += path + "/"; 
    url += item + "/";
    url += action + "/";
    url += argument;

    errorString = "Failed to " + action + " \"" + argument + "\"!";
  } else {
    url = "/cwa_browser/" + redmine_project + "/";
    url += share + "/";
    if (path)
      url += path + "/";
    url += item + "/";
    url += action;

    errorString = "Failed to " + action + " \"" + item + "\"!";
  }

  if (confirmBool) {
    if (confirm("Are you sure you want to " + action + " " + item + " ?")){
      continuation = true;
    }
  } else {
    continuation = true;
  }
      

  if ((promptString && argument && continuation == true) || 
      (!promptString && !argument && continuation == true)){
    $.ajax({
      type: "POST",
      url: url,
      success: function(data){ 
        if (data.fid != null){
          switch (data.type){
            case "application/x-directory; charset=binary":
              method = "downloadzip";
              break;
            default:
              method = "download";
          }
          window.location.assign("/cwa_browser/" + redmine_project + "/" + method + "/" + data.fid);
        } else {
          window.location.assign("/cwa_browser/" + redmine_project + "/" + share + "/" + path);
        }
      },
      error: function(data){ alert(errorString); }
    });
  }
};

function chdir(elem){
  components = path_components(elem);
  share = components.share;
  path = components.path;
  window.location = "/cwa_browser/" + redmine_project + "/" + share + "/" + path;
};

function chdirAppMgr(elem){
  [share,path] = path_components(elem);
  if (path != ""){
    url_path = "share=" + share + "&dir=" + encodeURIComponent(path);
  } else {
    url_path = "share=" + share;
  }
  window.location = "<%= request.path %>?" + url_path + "&" + $('#app_form').serialize();
};

function back(){
  window.location = "/cwa_browser/" + redmine_project + "/<%= @browser.current_share %>/<%= @browser.up_dir %>";
};

function backAppMgr(){
  window.location = "<%= request.path %>?share=<%= @browser.current_share %>&dir=" + encodeURIComponent("<%= @browser.up_dir %>") + "&" + $('#app_form').serialize();
};

// Dustin Diaz's getElementsByClass to search for elements by class name regex
function getElementsByClass(searchClass,node,tag) {
  var classElements = new Array();
  if ( node == null )
    node = document;
  if ( tag == null )
    tag = '*';
  var els = node.getElementsByTagName(tag);
  var elsLen = els.length;
  var pattern = new RegExp(searchClass);
  for (i = 0, j = 0; i < elsLen; i++) {
    if ( pattern.test(els[i].className) ) {
      classElements[j] = els[i];
      j++;
    }
  }
  return classElements;
}

function clear_selected(){
  var selected = getElementsByClass("^.*(File|Dir).*Selected$"),
    items = selected.length,
    element = null;
  for (var i = 0; i < items; i++){
    element = selected[i];
    new_name = element.className.replace("Selected","");
    element.className = new_name;
  }
}

// these methods are for mini-browsers for job submission
function set_selected_dir(elem, dir){
  $("#selected_dir").val(dir);
  var className = elem.className;
  var re = new RegExp(".*Selected$");
  if (!elem.className.match(re)){
    clear_selected();
    elem.className = className + "Selected";
  }
}

function set_selected_file(elem, dir, file){
  $("#selected_dir").val(dir);
  $("#selected_file").val(dir + "/" + file);
  var className = elem.className;
  var re = new RegExp(".*Selected$");
  if (!elem.className.match(re)){
    clear_selected();
    elem.className = className + "Selected";
  }
}

// these methods are for the full file browser
function select_directory(elem, targetDir){
  var className = elem.className;
  var re = new RegExp(".*Selected$");
  if (!elem.className.match(re)){
    clear_selected();
    elem.className = className + "Selected";
  }

  components = path_components(elem);
  share = components.share;
  path = components.path;

  if (targetDir){
    $("#target_dir").val(share + "/" + path);
    $("#target_item").val(share + "/" + path);
  } else {
    $("#selected_dir").val(share + "/" + path);
    $("#selected_item").val(share + "/" + path);
  }
}

function select_file(elem) {
  var className = elem.className;
  var re = new RegExp(".*Selected$");
  if (!elem.className.match(re)){
    clear_selected();
    elem.className = className + "Selected";
  }

  components = path_components(elem);
  share = components.share;
  path = components.path;

  $("#selected_file").val(share + "/" + path);
  $("#selected_item").val(share + "/" + path);
}

function showMenu(event, elementId) {
  /*  check whether the event is a right click 
   *  because different browser (ahem IE) assign different numbers to the keys to
   *  your mouse buttons and different values to the event, you'll have to do some evaluation
   */
  var rightclick; //will be set to true or false
  if (event.button) {
    rightclick = (event.button == 2);
  }
 
  if(rightclick) { //if the secondary mouse botton was clicked
    var menu = document.getElementById(elementId);
    menu.style.display = "block"; //show menu

    var x = event.clientX; //get X and Y coordinance for menu position
    var y = event.clientY;
 
    //This section is necessary if you click on the far right edge or bottom
    //The 200 is arbitrary, choose whatever number you want based on how large your menu is
    if(window.innerWidth) {
      windowWidth = window.innerWidth;
      windowHeight = window.innerHeight;
    } else if(document.documentElement.clientWidth) {
      windowWidth = document.documentElement.clientWidth;
      windowHeight = document.documentElement.clientHeight;
    } else {
      windowWidth = document.getElementsByTagName('body')[0].clientWidth;
      windowHeight = document.getElementsByTagName('body')[0].clientHeight;
    }
    if(windowWidth < (x + 200)) {
      x = x - 200;
    }
    if(windowHeight < (y + 200)) {
      y -= 200;
    }
 
    //position the menu
    menu.style.position = "fixed"; // use fixed or it will not work when the window is scrolled
    menu.style.top = y+"px";
    menu.style.left= x+"px";
  }
}
 
function clearMenu() { 
  $('#menuDir').css('display', 'none');
  $('#menuFile').css('display', 'none');
}

function showUploadFile(){
  $('#upload_form').attr('action', '/cwa_browser/' + redmine_project + '/' + $('#selected_share').val() + 
    "/" + $('#selected_dir').val() + "/upload");
  $('#upload').css("display", "block");
}

function hideUploadFile(){
  $('#upload').css("display", "none");
}

function uploadFile(){
  if ($('#selected_dir').val() == ''){
    var url = '/cwa_browser/' + redmine_project + '/' + $('#selected_share').val() + '/upload';
  } else {
    var url = '/cwa_browser/' + redmine_project + '/' + $('#selected_share').val() + '/' + $('#selected_dir').val() + '/upload';
  }

  $('#upload_form').attr('action', url);
}

// unhide the text editor div.  It will handle the rest
function showTextEditor(){
  $('#upload_form').attr('action', '/cwa_browser/' + redmine_project + '/' + $('#selected_share').val() + 
    "/" + $('#selected_dir').val() + "/create");
  $('#textEditor').css("display", "block");
}

// hide and reset the form in the text editor div
function hideTextEditor(){
  $('#textEditor').css("display","none");
  document.getElementById('new_file_form').reset();
}

// unhide the tail output div, then call my_tail_func every 5 seconds
// to update the form's content with the last 20 lines of output
function showTail(){
  $('#tail').css('display', "block");
  my_tail_func();
  tail_handle = setInterval(my_tail_func, 5000);
}

// hide the tail output div, and stop calling my_tail_func
function hideTail(){
  $('#tail').css('display', "none"); //don't show tail box
  document.getElementById('tail_box').reset();
  clearInterval(tail_handle);
}

// Show the move div
function showMove(){
  $('#move').css('display', "block");
}

// polling function to get progress of move
var move_id = '';
var move_interval;
var move_status = function(){
  $.getJSON('/cwa_browser/' + redmine_project + '/move_status/' + move_id, function(data){
    $.each(data, function(key,value){
      if (key == 'status'){
        #('#move_progress_bar_status').val(value);
        if (value == 'finished'){
          sleep(5);
          $('#move_progress').css('display', 'none'); 
        }
      }
      if (key == 'progress'){
        #('#move_progress_bar').val(value);
      } 
    });
  }); 
};

// Post a move to the server, initialize polling function to update progress indicator
function startMove(){
  $('#move').css('display', 'none');
  $('#move_progress_bar_status').val('starting');
  $('#move_progress_bar').val(0);

  var url_action = moveUrlAction();

  if (url_action){
    $.postJSON('/cwa_browser/' + redmine_project + '/' + url_action, function(data){
      $.each(data, function(key,value){
        if (key == 'move_id'){
          move_id = value;
        }
        if (key == 'status'){
          if (value != 'success'){
            $('#move_progress').css('display', 'block');
            $('#move_progress_bar_status').val('Failed!');
            sleep(5);
            $('#move_progress').css('display', 'none'); 
          } else { 
            $('#move_progress').css('display', 'block');
            move_interval = setInterval(move_status, 5000);
          }
        }
      });
    });
  }
}

// Create a URL suffix based on the current selected_file, selected_dir, target_file, target_dir
function moveUrlAction(){
  // possible actions:
  //
  // selected_share/selected_file/move/target_share
  // selected_share/selected_file/move/target_share/target_path
  // selected_share/selected_path/selected_file/move/target_share
  // selected_share/selected_path/selected_file/move/target_share/target_path
  // selected_share/selected_path/move/target_share
  // selected_share/selected_path/move/target_share/target_path
  
  var selected_share = $('#selected_share').val();
  var selected_path = $('#selected_dir').val();
  var selected_file = $('#selected_file').val();
  var target_share = $('#target_share').val();
  var target_path = $('#target_path').val();
  var url = false;

  if (!selected_share || !target_share){
    alert("Source and/or Target shares not properly set!");
  } else if (selected_share && !selected_path){
    alert("You cannot move " + selected_share + " to another location!");
  } else if (selected_share && selected_path && !selected_file && target_share && !target_path){
    url = selected_share + '/' + selected_path + '/move/' + target_share;
  } else if (selected_share && selected_path && selected_file && target_share && !target_path){
    url = selected_share + '/' + selected_path + '/' + selected_file + '/move/' + target_share;
  } else if (selected_share && selected_path && !selected_file && target_share && target_path){
    url = selected_share + '/' + selected_path + '/move/' + target_share + '/' + target_path;
  } else if (selected_share && selected_path && selected_file && target_share && target_path){
    url = selected_share + '/' + selected_path + '/' + selected_file + '/move/' + target_share + '/' + target_path;
  } else if (selected_share && !selected_path && selected_file && target_share && !target_path){
    url = selected_share + '/' + selected_file + '/move/' + target_share;
  } else if (selected_share && !selected_path && selected_file && target_share && target_path){
    url = selected_share + '/' + selected_file + '/move/' + target_share + '/' + target_path;
  }

  return url; 
}

// Parse out file items and return nicely-formatted HTML string
function getJSONfileItems(obj,share,path){
  var fileItems = [];
  for (var file in obj){
    if (!path){
      fileItems.push('<tr class="browserFileEntry" oncontextmenu="showMenu(event, ' + 
        "'menuFile'" + '); select_file(this);" onclick="select_file(this)" id="' + 
        share + '.' + file + '"><td><p class="browserEntryIcon">' + 
        file + "</p></td><td>" + obj[file]['user'] + "</td><td>" + obj[file]['group'] + "</td><td>" + 
        obj[file]['permissions'] + "</td><td>" + obj[file]['date'] + '</td></tr>');
    } else {
      fileItems.push('<tr class="browserFileEntry" oncontextmenu="showMenu(event, ' + 
        "'menuFile'" + '); select_file(this);" onclick="select_file(this)" id="' + 
        share + '.' + path + '/' + file + '"><td><p class="browserEntryIcon">' + 
        file + "</p></td><td>" + obj[file]['user'] + "</td><td>" + obj[file]['group'] + "</td><td>" + 
        obj[file]['permissions'] + "</td><td>" + obj[file]['date'] + '</td></tr>');
    }
  }
  return fileItems.join('\n');
}

// Parse out directory items and return nicely-formatted HTML string
function getJSONdirItems(obj,share,path,filePop){
  var dirItems = [];
  dirItems.push('<ul>');

  for (var dir in obj){
    if (!path){
      dirItems.push('<li class="dir" id="' + share + "." + dir + '" oncontextmenu="showMenu(event, ' + "'menuDir'" + '); select_directory(this,' + filePop + ');" onclick="collapsibleExpand(this,' + filePop + ');">' + dir + '</li>' );
    } else {
      dirItems.push('<li class="dir" id="' + share + "." + path + "/" + dir + '" oncontextmenu="showMenu(event, ' + "'menuDir'" + '); select_directory(this,' + filePop + ');" onclick="collapsibleExpand(this,' + filePop +');">' + dir + '</li>' );
    }
  }
  dirItems.push('</ul>');

  return dirItems.join('\n');
}

// This boldifies the currently selected directory element
function setEntrySelected(elem){
  $('#dirContainer').find('ul').css("font-weight", "normal");
  $('#dirContainer').find('li').css("font-weight", "normal");
  $(elem).css("font-weight", "bold");
}

// Expand tree based on current path
function goToPath(share, path){
  var dirItems = "";
  var fileItems = "";
  var path_elements = [];
  var dir = "";
  var dir_path = "";
  var eid = "";

  if (share == ""){
    share = "home";
  }

  path_elements = [share];

  if (path != null && path != ""){
    if (path.indexOf('/') === -1){
      path_elements.push(path);
    } else {
      path_elements = path_elements.concat(path.split('/'));
    }
  }

  $.each(path_elements, function(key,comp){
    switch (key){
      case 0:
        dir = comp;
        eid = comp + '.';
        break;
      case 1:
        dir_path = comp;
        dir = dir + '/' + comp;
        eid = eid + comp;
        break;
      default:
        dir_path = dir_path + '/' + comp;
        dir = dir + '/' + comp;
        eid = eid + '/' + comp;
    }

    $.ajaxSetup( { "async": false } ); 

    $.getJSON('/cwa_browser/' + redmine_project + '/' + dir, function(data){
      $.each(data,function(key,obj){
        if (key == 'directories'){
          dirItems = getJSONdirItems(obj,share,dir_path,true);
        }
        if (key == 'files'){
          fileItems = getJSONfileItems(obj,share,dir_path);
        }
      });

      var elem = document.getElementById(eid);

      setEntrySelected(elem);
      $(elem).attr('class','dirExpanded');
      $(dirItems).appendTo(elem);
      $("#fileContainer").html(fileItems);
    });
  });
  $("#current_dir").val(share + " => " + path);
}

// Handle the file tree view
function collapsibleExpand(elem,popFiles){
  if (elem.id != event.target.id){
    return;
  }

  var components = path_components(elem);
  var share = components.share;
  var path = components.path;
  var dirItems = "";
  var fileItems = "";

  $('#selected_share').val(share);
  $('#selected_dir').val(path);

  $.getJSON('/cwa_browser/' + redmine_project + '/' + share + "/" + path, function(data){

    if (elem.className == 'dirExpanded'){
      $(elem).find('ul').remove();
    }

    $.each(data, function(key,obj){
      if (key == 'directories' && elem.className != 'dirExpanded'){
        dirItems = getJSONdirItems(obj,share,path,popFiles);
      }
      if (key == 'files' && popFiles){
        fileItems = getJSONfileItems(obj,share,path);
      }
    });

    if (elem.className != 'dirExpanded'){
      elem.className = 'dirExpanded';
    } else {
      elem.className = 'dir';
    }

    setEntrySelected(elem);
    $(dirItems).appendTo(elem);
    if (popFiles){
      $("#fileContainer").html(fileItems);
      $("#current_dir").val(share + " => " + path);
    }
  });
}

// Given the element's id in share.path/to/something form, break up and return
// the components in a literal object
function path_components(elem){
  var parts = elem.id.split(".");
  var share = parts[0];
  parts.shift();
  var path = parts.join('.');
  
  return {
    share: share,
    path: path
  };
}
