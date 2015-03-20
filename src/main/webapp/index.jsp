<%@ page import="org.jsoup.Jsoup, org.jsoup.nodes.Document, org.jsoup.nodes.Element, org.jsoup.select.Elements" %>

<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Better Hacker News</title>
  <link href='//fonts.googleapis.com/css?family=Raleway:400,300,600' rel='stylesheet' type='text/css'>
  <link rel='stylesheet' href='//maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css'>
  <link rel='stylesheet' href='/custom.css'>

<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
  ga('create', 'UA-31301086-2', 'auto');
  ga('send', 'pageview');
</script>

</head>
<body>
  <div class="container">
    <div class="row">
      <div class="col-md-12">
        <h1 class="hidden-xs" align="center">Better Hacker News</h1><br>

<%    
Document doc = Jsoup.connect("https://news.ycombinator.com/").get();

Elements es = doc.select("span.deadmark");

for (Element e : es) {
    Element p = e.parent().child(1);

    String title = p.text();
    String value = p.attr("href");
%>

<h4><a href="<%= value %>"><%= title %></a></h4>
<p>
Description from meta tag or text for <%= title %>.
</p>
<hr>

<%
    /*try {
        Document item = Jsoup.connect(value).get();

        Elements esi = item.select("meta[name=description]");
        if (!esi.isEmpty()) {

            String desc = esi.first().attr("content");
            System.out.println("desc : " + desc);
        }
    } catch (Exception ee) {
        ee.printStackTrace();
    }*/
}
%>

        <p align="center">Stolen from <a href="https://news.ycombinator.com/">Hacker News</a></p>
        <p align="center"><a href="/hex.html">hex</a> | <a href="/html.html">html</a> | <a href="#">port</a></p>
      </div>
    </div>
  </div>
</body>
</html>
