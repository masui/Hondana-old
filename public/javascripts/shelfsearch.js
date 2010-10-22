var entry = [];
var urls = [];
var statuses = [];
var shelfnames = [];
var romas = [];
var descs = [];

var listtable;
var listdiv;
var listinitialized = false;

function getXmlHttpObject() {
  var xmlhttp;
  /*@cc_on
  @if (@_jscript_version >= 5)
    try {
      xmlhttp = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
      try {
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (E) {
        xmlhttp = false;
      }
    }
  @else
    xmlhttp = false;
  @end @*/
  if (!xmlhttp && typeof XMLHttpRequest != 'undefined') {
    try {
      xmlhttp = new XMLHttpRequest();
      xmlhttp.overrideMimeType("text/xml"); 
    } catch (e) {
      xmlhttp = false;
    }
  }
  return xmlhttp;
}

var xmlhttp;

function search(){
  if(!listinitialized){
    listinitialized = true;

    xmlhttp = getXmlHttpObject();
    xmlhttp.open("GET", "programs/list.js", true);
    xmlhttp.onreadystatechange = getres;
    xmlhttp.send(null);
  }
  else {
    display();
  }
}

function ajaxFilter(t){
  if(navigator.appVersion.indexOf( "KHTML" ) > -1){
    // Safariの文字化け対策
    // http://la.ma.la/blog/diary_200609220110.htm
    var esc = escape(t);
    return(esc.indexOf("%u") < 0 && esc.indexOf("%") > -1) ? decodeURIComponent(esc) : t
  }
  else {
    return t;
  }
}

function getres(){
  if (xmlhttp.readyState==4) {
    // list.js のデータ配列を取得
    ret = ajaxFilter(xmlhttp.responseText);
    eval(ret);

    for(var i=0;i<shelfnames.length;i++){
      var xtr, xtd, xa;
      xtr = document.createElement('tr');

      xtd = document.createElement('td');
      xtd.width = 150;
      xa = document.createElement('a');
      xa.href = urls[i];
      str = document.createTextNode(shelfnames[i]);
      xa.appendChild(str);
      xtd.appendChild(xa);
      xtr.appendChild(xtd);

      xtd = document.createElement('td');
      xtd.style.textAlign = 'right';
      str = document.createTextNode(statuses[i]+'冊');
      xtd.appendChild(str);
      xtr.appendChild(xtd);

      xtd = document.createElement('td');
      str = document.createTextNode(descs[i]);
      xtd.appendChild(str);
      xtr.appendChild(xtd);

      entry[i] = xtr;
    }
    display();
  }
}

function display(){
  var query = document.getElementById("query").value;
  var regexp = new RegExp(query);

  listdiv= document.getElementById("listdiv");

  // 古いリストを消去
  while(listdiv && listdiv.childNodes[0] != undefined){
    listdiv.removeChild(listdiv.childNodes[0]);
  }

  listtable = document.createElement('table');
  tbody = document.createElement('tbody');
  listtable.appendChild(tbody);
  if(listdiv) listdiv.appendChild(listtable);

  total = 0;
  for(var i=0;i<shelfnames.length && total < 20;i++){
    if(romas[i] && romas[i].match(regexp)){
      tbody.appendChild(entry[i]);
      total += 1;
    }
  }
}

// display();

search(); // 最初に検索してしまうように修正

