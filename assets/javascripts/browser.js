// Catch click events
$(document).click(function() {
  clearMenu();
});

function setPopupClickHandlers(){
  $('.dirEntryHomePopup,.dirEntrySharePopup,.dirEntryWorkPopup,.dirEntryDirPopup').unbind('click');
  $('.dirEntryHomePopup,.dirEntrySharePopup,.dirEntryWorkPopup').bind('click', function (event){
    event = event || window.event;
    event.preventDefault();
    leftClickShare(event,this,true);
    event.stopPropagation();
  });
  $('.dirEntryDirPopup').bind('click', function (event){
    event = event || window.event;
    event.preventDefault();
    leftClickDir(event,this,true);
    event.stopPropagation();
  });
}


function setClickHandlers(){
  // Unbind everything
  $('.dirEntryHome,.dirEntryShare,.dirEntryWork,.dirEntryDir').unbind('click');
  $('.dirEntryHome,.dirEntryShare,.dirEntryWork,.dirEntryDir').unbind('contextmenu');
  // Directory click handlers
  $('.dirEntryHome,.dirEntryShare,.dirEntryWork').bind('click', function (event){
    event = event || window.event;
    event.preventDefault();
    leftClickShare(event,this,false);
    event.stopPropagation();
  });
  $('.dirEntryDir').bind('click', function (event){
    event = event || window.event;
    event.preventDefault();
    leftClickDir(event,this,false);
    event.stopPropagation();
  });
  $('.dirEntryHome,.dirEntryShare,.dirEntryWork').bind('contextmenu', function (event){
    event = event || window.event;
    event.preventDefault();
    rightClickShare(event,this,false);
    event.stopPropagation();
  });
  $('.dirEntryDir').bind('contextmenu', function (event){
    event = event || window.event;
    event.preventDefault();
    rightClickDir(event,this,false);
    event.stopPropagation();
  });
  // File click handlers
  $('.browserFileEntry').bind('click', function (event){
    event = event || window.event;
    event.preventDefault();
    leftClickFile(event,this,false);
    event.stopPropagation();
  });
  $('.browserFileEntry').bind('contextmenu', function (event){
    event = event || window.event;
    event.preventDefault();
    rightClickFile(event,this,false);
    event.stopPropagation();
  });
}

function rightClickShare(event, element, divPopup){
  clearMenu();
  select_directory(element,divPopup);
  showMenu(event, 'menuShare');
}

function leftClickShare(event, element, divPopup){
  clearMenu();
  select_directory(element,divPopup);
  collapsibleExpand(element,divPopup);
}

function rightClickDir(event, element, divPopup){
  clearMenu();
  select_directory(element,divPopup);
  showMenu(event, 'menuDir');
}

function leftClickDir(event, element, divPopup){
  clearMenu();
  select_directory(element,divPopup);
  collapsibleExpand(element, divPopup);
}

function leftClickFile(event, element, divPopup){
  clearMenu();
  select_file(element);
}

function rightClickFile(event, element, divPopup){
  clearMenu();
  select_file(element);
  showMenu(event, 'menuFile');
}

// This should be set by the application first!
var redmine_project;
var submitClickFunction = null;
var fileObj;
var dirObj;

var tail_handle;
var my_tail_func = function(){
  var data = "";
  $.post("/cwa_browser/" + redmine_project + "/" + $('#selected_share').val() + '/' + $('#selected_file').val() + "/tail",
    function(data){ 
      $('#tail_content').val('');
      $('#tail_content').val(data);
    }
  );
  
  $("#tail_content").scrollTop($("#tail_content")[0].scrollHeight);
};

function cwaAction(action, promptString, confirmBool, itemType){
  
  var item = $('#selected_item').val();
  item = item.split("/");
  item = item[item.length-1];

  if (itemType === "dir"){
    var path = $("#selected_dir").val();
    var share = $("#selected_share").val();
  } else if (itemType === "file"){
    var share = $("#selected_share").val();
    var file = $("#selected_file").val();
  }
  
  var argument;
  var continuation = false;

  if (promptString){
    argument = prompt(promptString);
    url = "/cwa_browser/" + redmine_project + "/";
    if (file){
      url += share + '/' + file + '/' + action + '/' + argument;
    } else {
      url += share + '/' + path + '/' + action + '/' + argument;
    }
    errorString = "Failed to " + action + " \"" + argument + "\"!";
  } else {
    url = "/cwa_browser/" + redmine_project + "/";
    if (file){
      url += share + '/' + file + '/' + action;
    } else {
      url += share + '/' + path + '/' + action;
    }
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
    $.ajaxSetup( { "async": true } ); 
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
          goToPath(share, path, false);
        }
      },
      error: function(data){ alert(errorString); }
    });
  }
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

// these methods are for the full file browser
function select_directory(elem, divPopup){
  var components = path_components(elem);
  var share = components.share;
  var path = components.path;
  var dirName = components.path.split('/');

  if (divPopup){
    $("#target_share").val(share);
    $("#target_path").val(path);
  } else {
    $("#selected_file").val('');
    $("#selected_share").val(share);
    $("#selected_dir").val(path);
    $("#selected_item").val(share + "/" + path);
  }

  if (divPopup){
    $('.dirEntryHomePopup,.dirEntrySharePopup,.dirEntryWorkPopup,.dirEntryDirPopup').removeClass('dirSelected');
  } else {
    $('.dirEntryHome,.dirEntryShare,.dirEntryWork,.dirEntryDir').removeClass('dirSelected');
  }
  $(elem).addClass('dirSelected');

  $("#selected_file").val();
  $("#dirInfo").html(function(){
    for (var dirent in dirObj){
      if (dirent == dirName[dirName.length-1]){
        var str = "<b>Name: </b>" + dirent + "<br/>\n";
        str += "<b>Mode: </b>" + dirObj[dirent]['permissions'] + "<br/>\n";
        str += "<b>Owner: </b>" + dirObj[dirent]['user'] + "<br/>\n";
        str += "<b>Group: </b>" + dirObj[dirent]['group'] + "<br/>\n";
        str += "<b>Last change: </b>" + dirObj[dirent]['date'] + "<br/>\n";
        break;
      }
    }
    return str;
  });
}

function select_file(elem) {
  var className = elem.className;
  var re = new RegExp(".*Selected$");
  if (!elem.className.match(re)){
    clear_selected();
    elem.className = className + "Selected";
  }

  var components = path_components(elem);
  var share = components.share;
  var path = components.path;
  var fileName = components.path.split('/');

  $("#selected_file").val(path);
  $("#selected_item").val(share + "/" + path);
  $("#selected_share").val(share);
  $("#fileInfo").html(function(){
    for (var file in fileObj){
      if (file == fileName[fileName.length-1]){
        var str = "<b>Name: </b>" + file + "<br/>\n";
        str += "<b>Mode: </b>" + fileObj[file]['permissions'] + "<br/>\n";
        str += "<b>Owner: </b>" + fileObj[file]['user'] + "<br/>\n";
        str += "<b>Group: </b>" + fileObj[file]['group'] + "<br/>\n";
        str += "<b>Size: </b>" + getBytesWithUnit(fileObj[file]['size']) + "<br/>\n";
        str += "<b>Last change: </b>" + fileObj[file]['date'] + "<br/>\n";
        break;
      }
    }
    return str;
  });
}

var getBytesWithUnit = function( bytes ){
  if( isNaN( bytes ) ){ return; }
  var units = [ ' bytes', ' KB', ' MB', ' GB', ' TB', ' PB', ' EB', ' ZB', ' YB' ];
  var amountOf2s = Math.floor( Math.log( +bytes )/Math.log(2) );
  if( amountOf2s < 1 ){
    amountOf2s = 0;
  }
  var i = Math.floor( amountOf2s / 10 );
  bytes = +bytes / Math.pow( 2, 10*i );
 
  // Rounds to 3 decimals places.
  if( bytes.toString().length > bytes.toFixed(3).toString().length ){
    bytes = bytes.toFixed(3);
  }
  return bytes + units[i];
};

function showMenu(event, elementId) {
  /*  check whether the event is a right click 
   *  because different browser (ahem IE) assign different numbers to the keys to
   *  your mouse buttons and different values to the event, you'll have to do some evaluation
   */

  event.preventDefault();

  var rightclick; //will be set to true or false
  if (event.button) {
    rightclick = (event.button == 2);
  }
 
  if(rightclick) { //if the secondary mouse botton was clicked
    var menu = document.getElementById(elementId);
    if (menu == null){
      return;
    }
    $(menu).css('display', 'block'); //show menu
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
  $('#menuShare').css('display', 'none');
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
function showTextEditor(editFile){
  $('#new_file_form').attr('action', '/cwa_browser/' + redmine_project + '/' + $('#selected_share').val() + 
    "/" + $('#selected_dir').val() + "/create");
  if (editFile){
    url = "/cwa_browser/" + redmine_project + "/" + $('#selected_item').val() + '/download';
    // get file content from download and put into editor
    $.ajaxSetup( { "async": true } ); 
    $.ajax({
      type: "POST",
      url: url,
      success: function(data){ 
        if (!data.type.match(/^text\/.*/)){
          alert("File is not a text file so we can't edit it here :(");
        } else if (data.fid != null){
          $.ajax({
              type: "GET",
              url: "/cwa_browser/" + redmine_project + "/download/" + data.fid,
              success: function(getData){
                // this is defined by CodeMirror call earlier in the page :)
                var fileName = $('#selected_file').val().split('/');
                $('#textEditor').css("display", "block");
                $('#new_file_name').val(fileName[fileName.length-1]);
                textEditor.setValue(getData);
              },
              error: function(){
                alert("Problem opening file for editing...");
              }
          });
        } else {
          alert("Problem opening file for editing...");
        }
      },
      error: function(){
        alert("Problem opening file for editing...");
      }
    });
    
  } else {
    $('#textEditor').css("display", "block");
  }
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

// functions for application minibrowser for file and directory selection
function getSelectedDir(elem_id){
  $('#minibrowser').css('display', 'block');
  $('#minibrowser_button').attr('value', 'Select directory...');
  $('#minibrowser_button').attr('onclick', "miniBrowserSelectItem('dir', '" + elem_id + "',null)");
  goToPath("home",'',true);
}

function getSelectedFile(elem_id,inferWorkDir){
  $('#minibrowser').css('display', 'block');
  $('#minibrowser_button').attr('value', 'Select file...');
  $('#minibrowser_button').attr('onclick', "miniBrowserSelectItem('file', '" + elem_id + "','" + inferWorkDir + "')");
  goToPath("home",'',true);
}

function hideMiniBrowser(){
  $('#minibrowser').css('display', 'none');
}

function miniBrowserSelectItem(type, elem_id, inferWorkdir){
  if (type == 'file'){
    // We'll be infering the work directory from this.  We'll set the hidden
    // field work_dir
    var file = resolve_path($('#selected_share').val(), $('#selected_file').val());
    if (inferWorkdir != '' && inferWorkdir != null){
       var fileArray = file.split('/');
       fileArray.pop();
       work_dir = fileArray.join('/'); 
       var wdelem = document.getElementById(inferWorkdir);
       $(wdelem).val(work_dir);
    }
    var file_elem = document.getElementById(elem_id);
    var file_label_elem = document.getElementById(elem_id + "_label");
    $(file_elem).val(file);
    $(file_label_elem).html(file);
  } else if (type == 'dir'){
    var dir = resolve_path($('#selected_share').val(), $('#selected_dir').val());
    var dir_elem = document.getElementById(elem_id);
    var dir_label_elem = document.getElementById(elem_id + "_label");
    $(dir_elem).val(dir);
    $(dir_label_elem).html(dir);
  }
  hideMiniBrowser();
}

// Show the move div
function showCopyMove(action){
  setPopupClickHandlers();
  $('#copymove').css('display', "block");
  if (action == "move"){
    $('#copymove_button').attr('value', 'Move');
    $('#copymove_button').attr('onclick', "startCopyMove('move',null)");
  } else if (action == "copy") {
    $('#copymove_button').attr('value', 'Copy');
    $('#copymove_button').attr('onclick', "startCopyMove('copy',null)");
  }
  goToPath('home',null,true)
}

function hideCopyMove(){
  $('#copymove').css('display', 'none');
}

// polling function to get display progress of file operations
var op_id = '';
var op_interval = null;
var op_status = function(){
  $.getJSON('/cwa_browser/' + redmine_project + '/op_status/', function(data){
    console.log("op_status() " + JSON.stringify(data));
    if (data == null){
      clearInterval(op_interval);
      op_interval = null;
      $('#queue_progress').html('');
      $('#queue_progress').css('display', 'none');
      return false;
    } else {
      var op_items = [];
      $.each(data, function(key,op){
        op_items.push('<div id="' + key + '" class="browserProgressElement"><div id="shade_' + key + '" class="browserProgressElementShader" style="width:' + op.progress + '%"></div>' + op.operation + ' ' + op.file_name + '<br/>Status: ' + op.status + '</div>');
      });
      $('#queue_progress').html(op_items.join('\n'));
    }
  }); 
};

// Post a move to the server, initialize polling function to update progress indicator
function startCopyMove(action, elem_id){
  $('#copymove').css('display', 'none');
  if (action == "select"){
    var file_elem = document.getElementById(elem_id);
    var file_label_elem = document.getElementById(elem_id + "_selected");
    $(file_elem).html($('#selected_file').val());
    $(file_label_elem).html('[ ' +$('#selected_share').val() + ' ] / ' + $('#selected_file').val());
    return;
  }

  var url_action = copyMoveUrlAction(action);

  if (url_action){
    $.post('/cwa_browser/' + redmine_project + '/' + url_action, null, function(data){
      $.each(data, function(key, value){
        if (key == 'code'){
          $('#queue_progress').css('display', 'block');
          op_status();
          if (op_interval == null){
            op_interval = setInterval(op_status, 5000);
          }
          goToPath($('#target_share').val(),$('#target_path').val(),false);
        }
      });
    }, 'json');
  }
}

// Create a URL suffix based on the current selected_file, selected_dir, target_file, target_dir
function copyMoveUrlAction(action){
  var selected_share = $('#selected_share').val();
  var selected_dir = $('#selected_dir').val();
  var selected_file = $('#selected_file').val();
  var target_share = $('#target_share').val();
  var target_path = $('#target_path').val();
  var url = false;
  if (!selected_share || (!selected_file && !selected_dir) || !target_share){
    alert("Source and/or Target not properly set!");
  } else if (selected_file && target_share && !target_path){
    url = selected_share + '/' + selected_file + '/' + action + '/' + target_share;
  } else if (selected_file && target_share && target_path){
    url = selected_share + '/' + selected_file + '/' + action + '/' + target_share + '/' + target_path;
  } else if (!selected_file && selected_dir && target_share && target_path){
    url = selected_share + '/' + selected_dir + '/' + action + '/' + target_share + '/' + target_path;
  } else if (!selected_file && selected_dir && target_share && !target_path){
    url = selected_share + '/' + selected_dir + '/' + action + '/' + target_share;
  } else {
    alert("Invalid " + action + " request");
  }
  return url; 
}

// Parse out file items and return nicely-formatted HTML string
function getJSONfileItems(obj,share,path){
  var fileItems = [];
  for (var file in obj){
    if (!path){
      fileItems.push('<div class="browserFileEntry" id="' + 
        share + '.' + file + '"><p class="browserEntryText">' + 
        file + '</p></div>');
    } else {
      fileItems.push('<div class="browserFileEntry" id="' + 
        share + '.' + path + '/' + file + '"><p class="browserEntryText">' + 
        file + '</p></div>'); 
    }
  }
  return fileItems.join('\n');
}

// Parse out directory items and return nicely-formatted HTML string
function getJSONdirItems(obj,share,path,divPopup){
  var dirItems = [];
  dirItems.push('<ul>');
  var entryClass = divPopup ? 'dirEntryDirPopup' : 'dirEntryDir';

  for (var dir in obj){
    if (!path){
      dirItems.push('<li class="' + entryClass + '" id="' + share + "." + dir + '"><div>' + dir + '</div></li>' );
    } else {
      dirItems.push('<li class="' + entryClass + '" id="' + share + "." + path + "/" + dir + '"><div>' + dir + '</div></li>' );
    }
  }
  dirItems.push('</ul>');

  return dirItems.join('\n');
}

// Expand tree based on a provided path
function goToPath(share, path, divPopup){
  var dirItems = "";
  var fileItems = "";
  var path_elements = [];
  var dir = "";
  var dir_path = "";
  var eid = "";

  if (share == ""){
    share = "home";
  }

  if (!divPopup){
    $('#selected_dir').val('');
    $('#selected_file').val('');
  }

  $('#target_share').val('');
  $('#target_path').val('');

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
          dirObj = obj;
          dirItems = getJSONdirItems(obj,share,dir_path,divPopup);
        }
        if (key == 'files' && (!divPopup || $("#fileList_popup").length > 0)){
          fileObj = obj;
          fileItems = getJSONfileItems(obj,share,dir_path);
        }
      });

      var elem = document.getElementById(eid);

      $(elem).addClass('dirExpanded');
      $(elem).find('ul li').remove();
      $(dirItems).appendTo(elem);
      select_directory(elem,divPopup);

      if (divPopup && $("#fileList_popup").length > 0){
        $("#fileList_popup").html(fileItems);
      } else {
        $("#fileList").html(fileItems);
      }

      if (!divPopup){
        setClickHandlers();
      } else {
        setPopupClickHandlers();
      }
    });
  });
  var dispDir = resolve_path(share,path);
  if (!divPopup){
    $("#current_dir").html(dispDir);
  }else{
    $("#current_dir_popup").html(dispDir);
  }

}

// Expand tree and navigate based on current selected element
function collapsibleExpand(elem,divPopup){
  //if (elem.id != event.target.id){
  //  return;
  // }

  var components = path_components(elem);
  var share = components.share;
  var path = components.path;
  var dirItems = "";
  var fileItems = "";

  if (divPopup){
    $('#target_share').val(share);
    $('#target_path').val(path);
  } else {
    $('#selected_share').val(share);
    $('#selected_dir').val(path);
  }
  $.ajaxSetup( { "async": true } ); 
  $.getJSON('/cwa_browser/' + redmine_project + '/' + share + "/" + path, function(data){
    if($(elem).hasClass('dirExpanded')){
      $(elem).find('ul').remove();
     }
    $.each(data, function(key,obj){
      if (key == 'directories' && !$(elem).hasClass('dirExpanded')){
        dirItems = getJSONdirItems(obj,share,path,divPopup);
        dirObj = obj;
        $(dirItems).appendTo(elem);
      }
      if (key == 'files' && (!divPopup || $("#fileList_popup").length > 0)){
        fileItems = getJSONfileItems(obj,share,path);
        fileObj = obj;
        if (divPopup && $("#fileList_popup").length > 0){
          $("#fileList_popup").html(fileItems);
        } else {
          $("#fileList").html(fileItems);
        }
      }
    });
    var dispDir = resolve_path(share,path);
    if (!divPopup){
      $("#current_dir").html(dispDir);
      setClickHandlers();
    }else{
      $("#current_dir_popup").html(dispDir);
      setPopupClickHandlers();
    }
    if($(elem).hasClass('dirExpanded')){
      $(elem).removeClass('dirExpanded');
    } else {
      $(elem).addClass('dirExpanded');
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

// Given the share and path/to/something, resolve the full path
function resolve_path(share,path){
  var file = "";
  var home = $('#user_home_dir').val();
  var work = $('#user_work_dir').val();

  if (path != "" && path != null) {
    switch (share){
      case "home":
        file = home + "/" + path;
        break;
      case "work":
        file = work + "/" + path;
        break;
      case "shares":
        file = "/shares/" + path;
        break;
    }
  } else {
    switch(share){
      case "home":
        file = home;
        break;
      case "work":
        file = work;
        break;
      case "shares":
        file = null;
        break;
    }
  }
  return file;
}

function submitClick(submitClickFunction){
  if (submitClickFunction != null){
    return submitClickFunction();
  }
}

