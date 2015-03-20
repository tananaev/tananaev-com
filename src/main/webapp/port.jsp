<%@ page import="org.apache.http.client.fluent.Form, org.apache.http.client.fluent.Request" %>

<%

boolean open = Request.Post("http://ports.yougetsignal.com/check-port.php")
    .bodyForm(Form.form().add("remoteAddress", request.getParameter("address")).add("portNumber", request.getParameter("port")).build())
    .execute().returnContent().asString().contains("is open");

%>

{ "open": <%= open %> }
