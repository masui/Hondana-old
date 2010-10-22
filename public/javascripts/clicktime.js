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

document.onmousedown = mousedown;

function mousedown(){
  xmlhttp = getXmlHttpObject();
  // cgi = "http://www.hondana.org/programs/tellclick.cgi?shelf=daidea&isbn=4620317187";
  cgi = "<%= url_for :action => 'clicktime', :shelfname => @shelf.name, :isbn => @book.isbn %>";
  xmlhttp.open("GET", cgi);
  xmlhttp.send(null);
}
